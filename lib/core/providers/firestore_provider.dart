import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/services/firestore_service.dart';
import 'auth_provider.dart';
import 'package:clinic_app/features/admin/domain/models/admin_stats_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/profile/domain/models/user_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

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

final clinicAppointmentsStreamProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, clinicId) {
  return ref
      .watch(firestoreServiceProvider)
      .getClinicAppointmentsStream(clinicId);
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

  return firestore.collection('clinics').snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => ClinicModel.fromJson(doc.data()))
        .toList();
  });
});

final userListProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore.collection('users').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  });
});
