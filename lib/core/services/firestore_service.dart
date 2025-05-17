import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/features/patient/domain/models/patient_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get clinicsCollection => _firestore.collection('clinics');
  CollectionReference get proceduresCollection =>
      _firestore.collection('procedures');
  CollectionReference get appointmentsCollection =>
      _firestore.collection('appointments');
  CollectionReference get stockItemsCollection =>
      _firestore.collection('stock_items');

  // Patient Collection
  CollectionReference get patientsCollection =>
      _firestore.collection('patients');

  // Generic CRUD operations
  Future<DocumentReference> addDocument(
    CollectionReference collection,
    Map<String, dynamic> data,
  ) async {
    return await collection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDocument(
    CollectionReference collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await collection.doc(documentId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDocument(
    CollectionReference collection,
    String documentId,
  ) async {
    await collection.doc(documentId).delete();
  }

  Future<DocumentSnapshot> getDocument(
    CollectionReference collection,
    String documentId,
  ) async {
    return await collection.doc(documentId).get();
  }

  Stream<QuerySnapshot> getCollectionStream(CollectionReference collection) {
    return collection.orderBy('createdAt', descending: true).snapshots();
  }

  // Specific queries
  Stream<QuerySnapshot> getActiveClinicStream() {
    return clinicsCollection.where('isActive', isEqualTo: true).snapshots();
  }

  Stream<QuerySnapshot> getUpcomingAppointmentsStream() {
    return appointmentsCollection
        .where('dateTime', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('dateTime')
        .snapshots();
  }

  Stream<QuerySnapshot> getLowStockItemsStream() {
    return stockItemsCollection
        .where('quantity', isLessThanOrEqualTo: 10)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserAppointmentsStream(String userId) {
    return appointmentsCollection
        .where('patientId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getClinicAppointmentsStream(String clinicId) {
    return appointmentsCollection
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  // Batch operations
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    final batch = _firestore.batch();

    for (var update in updates) {
      final doc = update['collection'].doc(update['documentId']);
      batch.update(doc, update['data']);
    }

    await batch.commit();
  }

  // Transaction operations
  Future<void> transferStock(
    String fromClinicId,
    String toClinicId,
    String itemId,
    int quantity,
  ) async {
    await _firestore.runTransaction((transaction) async {
      final fromDoc = stockItemsCollection.doc(fromClinicId);
      final toDoc = stockItemsCollection.doc(toClinicId);

      final fromSnapshot = await transaction.get(fromDoc);
      final toSnapshot = await transaction.get(toDoc);

      final fromQuantity = fromSnapshot.get('quantity') as int;
      final toQuantity = toSnapshot.get('quantity') as int;

      if (fromQuantity < quantity) {
        throw Exception('Insufficient stock');
      }

      transaction.update(fromDoc, {'quantity': fromQuantity - quantity});
      transaction.update(toDoc, {'quantity': toQuantity + quantity});
    });
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Stream<Map<String, dynamic>?> watchUserData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<void> addAppointment({
    required String clinicId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String procedureId,
    required String operatorId,
    required DateTime dateTime,
    String? notes,
  }) async {
    try {
      // İşlem detaylarını al
      final procedureDoc = await proceduresCollection.doc(procedureId).get();
      if (!procedureDoc.exists) {
        throw Exception('İşlem bulunamadı');
      }

      final procedureData = procedureDoc.data() as Map<String, dynamic>;
      final materials = procedureData['materials'] as List<dynamic>? ?? [];

      // Stok ürünlerinin maliyetlerini al
      final usedStockItems = await Future.wait(materials.map((material) async {
        final stockItemDoc =
            await stockItemsCollection.doc(material['stockItemId']).get();
        if (!stockItemDoc.exists) {
          throw Exception(
              'Stok ürünü bulunamadı: ${material['stockItemName']}');
        }

        final stockData = stockItemDoc.data() as Map<String, dynamic>;
        return {
          'id': material['stockItemId'],
          'name': material['stockItemName'],
          'quantity': material['quantity'],
          'unit': material['unit'],
          'cost': stockData['cost'] ?? 0.0,
        };
      }));

      final appointmentData = {
        'clinicId': clinicId,
        'patientId': patientId,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'procedureId': procedureId,
        'operatorId': operatorId,
        'dateTime': Timestamp.fromDate(dateTime),
        'notes': notes,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'usedStockItems': usedStockItems,
      };

      final docRef = await appointmentsCollection.add(appointmentData);
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  // Patient operations
  Future<void> addPatient(PatientModel patient) async {
    try {
      final docRef = await patientsCollection.add(patient.toJson());
      await docRef.update({'id': docRef.id});

      // Klinik dokümanını güncelle
      await clinicsCollection.doc(patient.clinicId).update({
        'patientIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add patient: $e');
    }
  }

  Future<void> updatePatient(PatientModel patient) async {
    try {
      await patientsCollection.doc(patient.id).update({
        ...patient.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  Future<void> deletePatient(String patientId, String clinicId) async {
    try {
      // Hasta dokümanını sil
      await patientsCollection.doc(patientId).delete();

      // Klinik dokümanını güncelle
      await clinicsCollection.doc(clinicId).update({
        'patientIds': FieldValue.arrayRemove([patientId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }

  Future<PatientModel?> getPatient(String patientId) async {
    try {
      final doc = await patientsCollection.doc(patientId).get();
      if (!doc.exists) return null;
      return PatientModel.fromJson(
          {...doc.data() as Map<String, dynamic>, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get patient: $e');
    }
  }

  Stream<QuerySnapshot> getClinicPatientsStream(String clinicId) {
    return patientsCollection
        .where('clinicId', isEqualTo: clinicId)
        .snapshots();
  }

  Future<List<PatientModel>> searchPatients(
      String clinicId, String query) async {
    try {
      final snapshot = await patientsCollection
          .where('clinicId', isEqualTo: clinicId)
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PatientModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to search patients: $e');
    }
  }

  Future<void> updateAppointment({
    required String appointmentId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String procedureId,
    required String operatorId,
    required DateTime dateTime,
    String? notes,
    String? status,
    double? paymentAmount,
    String? paymentMethod,
    String? paymentNote,
  }) async {
    try {
      // İşlem detaylarını al
      final procedureDoc = await proceduresCollection.doc(procedureId).get();
      if (!procedureDoc.exists) {
        throw Exception('İşlem bulunamadı');
      }

      final procedureData = procedureDoc.data() as Map<String, dynamic>;
      final materials = procedureData['materials'] as List<dynamic>? ?? [];

      // Stok ürünlerinin maliyetlerini al
      final usedStockItems = await Future.wait(materials.map((material) async {
        final stockItemDoc =
            await stockItemsCollection.doc(material['stockItemId']).get();
        if (!stockItemDoc.exists) {
          throw Exception(
              'Stok ürünü bulunamadı: ${material['stockItemName']}');
        }

        final stockData = stockItemDoc.data() as Map<String, dynamic>;
        return {
          'id': material['stockItemId'],
          'name': material['stockItemName'],
          'quantity': material['quantity'],
          'unit': material['unit'],
          'cost': stockData['cost'] ?? 0.0,
        };
      }));

      final appointmentData = {
        'patientId': patientId,
        'patientName': patientName,
        'patientPhone': patientPhone,
        'procedureId': procedureId,
        'operatorId': operatorId,
        'dateTime': Timestamp.fromDate(dateTime),
        'notes': notes,
        'status': status ?? 'scheduled',
        'updatedAt': FieldValue.serverTimestamp(),
        'paymentAmount': paymentAmount,
        'paymentMethod': paymentMethod,
        'paymentNote': paymentNote,
        'paymentDate':
            paymentAmount != null ? FieldValue.serverTimestamp() : null,
        'usedStockItems': usedStockItems,
      };

      // Eğer stok ürünleri kullanıldıysa, stok miktarlarını güncelle
      if (usedStockItems.isNotEmpty) {
        final batch = _firestore.batch();

        for (var item in usedStockItems) {
          final stockItemRef = stockItemsCollection.doc(item['id']);
          final stockItem = await stockItemRef.get();

          if (stockItem.exists) {
            final currentQuantity = stockItem.get('quantity') as num;
            final usedQuantity = item['quantity'] as num;

            batch.update(stockItemRef, {
              'quantity': currentQuantity - usedQuantity,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        // Önce stok güncellemelerini yap
        await batch.commit();
      }

      // Sonra randevuyu güncelle
      await appointmentsCollection.doc(appointmentId).update(appointmentData);
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
