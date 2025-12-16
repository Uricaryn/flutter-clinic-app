import 'package:clinic_app/core/services/database_service.dart';
import 'package:clinic_app/core/services/firestore_service.dart';
import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';
import 'package:clinic_app/features/patient/domain/models/patient_model.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/clinic/domain/models/expense_model.dart';
import 'package:clinic_app/features/operator/domain/models/operator_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase/Firestore database service implementation
///
/// This wraps the existing FirestoreService to implement the DatabaseService interface.
/// This allows the app to use the same interface for both Firebase and PostgreSQL.
class FirebaseDatabaseService implements DatabaseService {
  final FirestoreService _firestore = FirestoreService();

  // ============================================================================
  // APPOINTMENTS
  // ============================================================================

  @override
  Future<List<AppointmentModel>> getAppointments(String clinicId) async {
    final snapshot = await _firestore.appointmentsCollection
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AppointmentModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  @override
  Future<AppointmentModel> getAppointment(String appointmentId) async {
    final doc =
        await _firestore.appointmentsCollection.doc(appointmentId).get();
    return AppointmentModel.fromJson(
        {...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  @override
  Future<String> addAppointment(AppointmentModel appointment) async {
    final data = appointment.toJson();
    data.remove('id'); // Remove id as it will be generated

    final docRef = await _firestore.appointmentsCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _firestore.appointmentsCollection.doc(appointment.id).update({
      ...appointment.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.deleteAppointment(appointmentId);
  }

  @override
  Stream<List<AppointmentModel>> watchAppointments(String clinicId) {
    return _firestore.getClinicAppointmentsStream(clinicId).map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  @override
  Stream<List<AppointmentModel>> watchUpcomingAppointments(String clinicId) {
    return _firestore.getUpcomingAppointmentsStream().map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  // ============================================================================
  // PATIENTS
  // ============================================================================

  @override
  Future<List<PatientModel>> getPatients(String clinicId) async {
    final snapshot = await _firestore.patientsCollection
        .where('clinicId', isEqualTo: clinicId)
        .get();

    return snapshot.docs
        .map((doc) => PatientModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  @override
  Future<PatientModel> getPatient(String patientId) async {
    final patient = await _firestore.getPatient(patientId);
    if (patient == null) {
      throw Exception('Patient not found');
    }
    return patient;
  }

  @override
  Future<String> addPatient(PatientModel patient) async {
    await _firestore.addPatient(patient);
    return patient.id;
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    await _firestore.updatePatient(patient);
  }

  @override
  Future<void> deletePatient(String patientId, String clinicId) async {
    await _firestore.deletePatient(patientId, clinicId);
  }

  @override
  Stream<List<PatientModel>> watchPatients(String clinicId) {
    return _firestore.getClinicPatientsStream(clinicId).map((snapshot) {
      return snapshot.docs
          .map((doc) => PatientModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  @override
  Future<List<PatientModel>> searchPatients(
      String clinicId, String query) async {
    return await _firestore.searchPatients(clinicId, query);
  }

  // ============================================================================
  // PROCEDURES
  // ============================================================================

  @override
  Future<List<ProcedureModel>> getProcedures(String clinicId) async {
    final snapshot = await _firestore.proceduresCollection
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProcedureModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  @override
  Future<ProcedureModel> getProcedure(String procedureId) async {
    final doc = await _firestore.proceduresCollection.doc(procedureId).get();
    return ProcedureModel.fromJson(
        {...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  @override
  Future<String> addProcedure(ProcedureModel procedure) async {
    final data = procedure.toJson();
    data.remove('id');

    final docRef = await _firestore.proceduresCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<void> updateProcedure(ProcedureModel procedure) async {
    await _firestore.proceduresCollection.doc(procedure.id).update({
      ...procedure.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteProcedure(String procedureId) async {
    await _firestore.proceduresCollection.doc(procedureId).delete();
  }

  @override
  Stream<List<ProcedureModel>> watchProcedures(String clinicId) {
    return _firestore.getProceduresStream().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProcedureModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  // ============================================================================
  // STOCK ITEMS
  // ============================================================================

  @override
  Future<List<StockItemModel>> getStockItems(String clinicId) async {
    final snapshot = await _firestore.stockItemsCollection
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => StockItemModel.fromJson(
            {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  @override
  Future<StockItemModel> getStockItem(String stockItemId) async {
    final doc = await _firestore.stockItemsCollection.doc(stockItemId).get();
    return StockItemModel.fromJson(
        {...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  @override
  Future<String> addStockItem(StockItemModel stockItem) async {
    final data = stockItem.toJson();
    data.remove('id');

    final docRef = await _firestore.stockItemsCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<void> updateStockItem(StockItemModel stockItem) async {
    await _firestore.stockItemsCollection.doc(stockItem.id).update({
      ...stockItem.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteStockItem(String stockItemId) async {
    await _firestore.stockItemsCollection.doc(stockItemId).delete();
  }

  @override
  Stream<List<StockItemModel>> watchStockItems(String clinicId) {
    return _firestore.getStockItemsStream().map((snapshot) {
      return snapshot.docs
          .map((doc) => StockItemModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  @override
  Stream<List<StockItemModel>> watchLowStockItems(String clinicId) {
    return _firestore.getLowStockItemsStream().map((snapshot) {
      return snapshot.docs
          .map((doc) => StockItemModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  // ============================================================================
  // CLINICS
  // ============================================================================

  @override
  Future<ClinicModel?> getClinic(String clinicId) async {
    try {
      final doc = await _firestore.clinicsCollection.doc(clinicId).get();
      if (!doc.exists) return null;
      return ClinicModel.fromJson(
          {...doc.data() as Map<String, dynamic>, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> addClinic(ClinicModel clinic) async {
    final data = clinic.toJson();
    data.remove('id');

    final docRef = await _firestore.clinicsCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<void> updateClinic(ClinicModel clinic) async {
    await _firestore.clinicsCollection.doc(clinic.id).update({
      ...clinic.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<ClinicModel?> watchClinic(String clinicId) {
    return _firestore.clinicsCollection.doc(clinicId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ClinicModel.fromJson(
          {...doc.data() as Map<String, dynamic>, 'id': doc.id});
    });
  }

  // ============================================================================
  // EXPENSES
  // ============================================================================

  @override
  Future<List<ExpenseModel>> getExpenses(String clinicId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('clinicId', isEqualTo: clinicId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<String> addExpense(ExpenseModel expense) async {
    final data = expense.toJson();
    data.remove('id');

    final docRef = await FirebaseFirestore.instance.collection('expenses').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(expense.id)
        .update({
      ...expense.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // ============================================================================
  // OPERATORS
  // ============================================================================

  @override
  Future<List<OperatorModel>> getOperators(String clinicId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('operators')
        .where('clinicId', isEqualTo: clinicId)
        .get();

    return snapshot.docs
        .map((doc) => OperatorModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<String> addOperator(OperatorModel operator) async {
    final data = operator.toJson();
    data.remove('id');

    final docRef =
        await FirebaseFirestore.instance.collection('operators').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  @override
  Future<void> updateOperator(OperatorModel operator) async {
    await FirebaseFirestore.instance
        .collection('operators')
        .doc(operator.id)
        .update({
      ...operator.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteOperator(String operatorId) async {
    await FirebaseFirestore.instance
        .collection('operators')
        .doc(operatorId)
        .delete();
  }

  // ============================================================================
  // USER DATA
  // ============================================================================

  @override
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _firestore.updateUserData(userId, data);
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    return await _firestore.getUserData(userId);
  }

  @override
  Stream<Map<String, dynamic>?> watchUserData(String userId) {
    return _firestore.watchUserData(userId);
  }
}
