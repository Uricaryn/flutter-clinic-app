import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/services/firestore_service.dart';
import 'auth_provider.dart';
import 'package:clinic_app/features/admin/domain/models/admin_stats_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/profile/domain/models/user_model.dart';
import 'package:clinic_app/features/patient/domain/models/patient_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final clinicServiceProvider = Provider<ClinicService>((ref) {
  return ClinicService(FirebaseFirestore.instance);
});

class ClinicService {
  final FirebaseFirestore _firestore;

  ClinicService(this._firestore);

  Future<void> addClinic(ClinicModel clinic) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final clinicData = {
      ...clinic.toJson(),
      'ownerId': user.uid,
      'patientIds': [],
      'operatorIds': [],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final docRef = await _firestore.collection('clinics').add(clinicData);
    await docRef.update({'id': docRef.id});

    // Kullanıcı dokümanını güncelle
    await _firestore.collection('users').doc(user.uid).update({
      'clinicId': docRef.id,
      'role': 'clinic_owner',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateClinic(ClinicModel clinic) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Klinik sahibi kontrolü
    final clinicDoc =
        await _firestore.collection('clinics').doc(clinic.id).get();
    if (!clinicDoc.exists) throw Exception('Clinic not found');

    final clinicData = clinicDoc.data();
    if (clinicData?['ownerId'] != user.uid) {
      throw Exception('You are not authorized to update this clinic');
    }

    // Mevcut ilişkili verileri koru
    final existingData = clinicDoc.data() as Map<String, dynamic>;
    final updatedData = {
      ...clinic.toJson(),
      'patientIds': existingData['patientIds'] ?? [],
      'operatorIds': existingData['operatorIds'] ?? [],
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _firestore.collection('clinics').doc(clinic.id).update(updatedData);
  }

  Future<void> deleteClinic(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Klinik sahibi kontrolü
    final clinicDoc = await _firestore.collection('clinics').doc(id).get();
    if (!clinicDoc.exists) throw Exception('Clinic not found');

    final clinicData = clinicDoc.data();
    if (clinicData?['ownerId'] != user.uid) {
      throw Exception('You are not authorized to delete this clinic');
    }

    // İlişkili verileri temizle
    final batch = _firestore.batch();

    // Operatörlerin clinicId'sini temizle
    final operators = await _firestore
        .collection('users')
        .where('clinicId', isEqualTo: id)
        .get();

    for (var operator in operators.docs) {
      batch.update(operator.reference, {
        'clinicId': FieldValue.delete(),
        'role': 'user',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    // Hastaların clinicId'sini temizle
    final patients = await _firestore
        .collection('users')
        .where('clinicId', isEqualTo: id)
        .get();

    for (var patient in patients.docs) {
      batch.update(patient.reference, {
        'clinicId': FieldValue.delete(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    // Klinik dokümanını sil
    batch.delete(_firestore.collection('clinics').doc(id));

    // Kullanıcı dokümanını güncelle
    batch.update(_firestore.collection('users').doc(user.uid), {
      'clinicId': FieldValue.delete(),
      'role': 'user',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  // İlişkili verileri getir
  Future<Map<String, dynamic>> getClinicDetails(String clinicId) async {
    final clinicDoc =
        await _firestore.collection('clinics').doc(clinicId).get();
    if (!clinicDoc.exists) throw Exception('Clinic not found');

    final clinicData = clinicDoc.data() as Map<String, dynamic>;
    final patientIds = List<String>.from(clinicData['patientIds'] ?? []);
    final operatorIds = List<String>.from(clinicData['operatorIds'] ?? []);

    // Hastaları getir
    final patients = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: patientIds)
        .get();

    // Operatörleri getir
    final operators = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: operatorIds)
        .get();

    return {
      'clinic': ClinicModel.fromJson({...clinicData, 'id': clinicDoc.id}),
      'patients': patients.docs.map((doc) => doc.data()).toList(),
      'operators': operators.docs.map((doc) => doc.data()).toList(),
    };
  }

  Future<void> addAppointment({
    required String clinicId,
    required String patientName,
    required String patientPhone,
    required String procedureId,
    required String operatorId,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      final appointmentData = {
        'clinicId': clinicId,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'procedureId': procedureId,
        'operatorId': operatorId,
        'dateTime': Timestamp.fromDate(dateTime),
        'notes': notes,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('appointments').add(appointmentData);
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  Future<void> addPatient(PatientModel patient) async {
    final docRef = _firestore.collection('patients').doc();
    await docRef.set({
      ...patient.toJson(),
      'id': docRef.id,
    });
  }

  Future<void> updatePatient(PatientModel patient) async {
    await _firestore.collection('patients').doc(patient.id).update({
      'fullName': patient.fullName,
      'email': patient.email,
      'phone': patient.phone,
      'address': patient.address,
      'dateOfBirth': Timestamp.fromDate(patient.dateOfBirth),
      'gender': patient.gender,
      'notes': patient.notes,
      'updatedAt': Timestamp.fromDate(patient.updatedAt!),
    });
  }

  Future<void> deletePatient(String patientId) async {
    // Önce hastanın randevularını kontrol et
    final appointments = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();

    if (appointments.docs.isNotEmpty) {
      throw Exception(
          'Bu hastaya ait randevular var. Önce randevuları iptal edin.');
    }

    // Hastayı sil
    await _firestore.collection('patients').doc(patientId).delete();
  }
}

// Collection stream providers
final usersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getCollectionStream(
        ref.watch(firestoreServiceProvider).usersCollection,
      );
});

final clinicsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getCollectionStream(
        ref.watch(firestoreServiceProvider).clinicsCollection,
      );
});

final proceduresStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getCollectionStream(
        ref.watch(firestoreServiceProvider).proceduresCollection,
      );
});

final appointmentsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getCollectionStream(
        ref.watch(firestoreServiceProvider).appointmentsCollection,
      );
});

final stockItemsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getCollectionStream(
        ref.watch(firestoreServiceProvider).stockItemsCollection,
      );
});

// Specific query providers
final activeClinicStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getActiveClinicStream();
});

final upcomingAppointmentsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getUpcomingAppointmentsStream();
});

final lowStockItemsStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.watch(firestoreServiceProvider).getLowStockItemsStream();
});

// User-specific providers
final userAppointmentsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUserAppointmentsStream(userId);
});

// Klinik randevularını getir
final clinicAppointmentsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, clinicId) {
  return FirebaseFirestore.instance
      .collection('appointments')
      .where('clinicId', isEqualTo: clinicId)
      .snapshots();
});

// Current user's data provider
final currentUserDataProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return ref
      .watch(firestoreServiceProvider)
      .usersCollection
      .doc(user.uid)
      .snapshots();
});

// Loading state providers
final firestoreLoadingProvider = StateProvider<bool>((ref) => false);
final firestoreErrorProvider = StateProvider<String?>((ref) => null);

// Search providers
final clinicSearchProvider = StateProvider<String>((ref) => '');
final procedureSearchProvider = StateProvider<String>((ref) => '');

// Filtered stream providers
final filteredClinicsProvider =
    StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final searchTerm = ref.watch(clinicSearchProvider).toLowerCase();
  final clinicsStream = ref.watch(clinicsStreamProvider);

  return clinicsStream.when(
    data: (snapshot) {
      if (searchTerm.isEmpty) return Stream.value(snapshot.docs);
      return Stream.value(snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'].toString().toLowerCase().contains(searchTerm);
      }).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final filteredProceduresProvider =
    StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final searchTerm = ref.watch(procedureSearchProvider).toLowerCase();
  final proceduresStream = ref.watch(proceduresStreamProvider);

  return proceduresStream.when(
    data: (snapshot) {
      if (searchTerm.isEmpty) return Stream.value(snapshot.docs);
      return Stream.value(snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'].toString().toLowerCase().contains(searchTerm);
      }).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final adminStatsProvider = StreamProvider<AdminStats>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('admin_stats')
      .doc('current')
      .snapshots()
      .map((doc) {
    if (!doc.exists) {
      return AdminStats(
        totalClinics: 0,
        activeClinics: 0,
        totalUsers: 0,
        totalAppointments: 0,
      );
    }
    return AdminStats.fromJson(doc.data()!);
  });
});

final clinicListProvider = StreamProvider<List<ClinicModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('clinics')
      .where('ownerId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ClinicModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  });
});

final userListProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore.collection('users').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  });
});

final clinicStockStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, clinicId) {
  return FirebaseFirestore.instance
      .collection('stock_items')
      .where('clinicId', isEqualTo: clinicId)
      .snapshots();
});

final clinicExpensesStreamProvider =
    StreamProvider.family<List<QueryDocumentSnapshot>, String>((ref, clinicId) {
  return FirebaseFirestore.instance
      .collection('expenses')
      .where('clinicId', isEqualTo: clinicId)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

final clinicProceduresStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, clinicId) {
  return FirebaseFirestore.instance
      .collection('procedures')
      .where('clinicId', isEqualTo: clinicId)
      .snapshots();
});
