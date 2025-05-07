import 'package:cloud_firestore/cloud_firestore.dart';

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
}
