/// Abstract interface for database operations
///
/// This allows the app to switch between Firebase and PostgreSQL
/// without changing the business logic.
///
/// Implementations:
/// - FirebaseDatabaseService: Uses Firestore
/// - PostgresqlDatabaseService: Uses REST API + PostgreSQL

import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';
import 'package:clinic_app/features/patient/domain/models/patient_model.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/clinic/domain/models/expense_model.dart';
import 'package:clinic_app/features/operator/domain/models/operator_model.dart';

abstract class DatabaseService {
  // Appointments
  Future<List<AppointmentModel>> getAppointments(String clinicId);
  Future<AppointmentModel> getAppointment(String appointmentId);
  Future<String> addAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String appointmentId);
  Stream<List<AppointmentModel>> watchAppointments(String clinicId);
  Stream<List<AppointmentModel>> watchUpcomingAppointments(String clinicId);

  // Patients
  Future<List<PatientModel>> getPatients(String clinicId);
  Future<PatientModel> getPatient(String patientId);
  Future<String> addPatient(PatientModel patient);
  Future<void> updatePatient(PatientModel patient);
  Future<void> deletePatient(String patientId, String clinicId);
  Stream<List<PatientModel>> watchPatients(String clinicId);
  Future<List<PatientModel>> searchPatients(String clinicId, String query);

  // Procedures
  Future<List<ProcedureModel>> getProcedures(String clinicId);
  Future<ProcedureModel> getProcedure(String procedureId);
  Future<String> addProcedure(ProcedureModel procedure);
  Future<void> updateProcedure(ProcedureModel procedure);
  Future<void> deleteProcedure(String procedureId);
  Stream<List<ProcedureModel>> watchProcedures(String clinicId);

  // Stock Items
  Future<List<StockItemModel>> getStockItems(String clinicId);
  Future<StockItemModel> getStockItem(String stockItemId);
  Future<String> addStockItem(StockItemModel stockItem);
  Future<void> updateStockItem(StockItemModel stockItem);
  Future<void> deleteStockItem(String stockItemId);
  Stream<List<StockItemModel>> watchStockItems(String clinicId);
  Stream<List<StockItemModel>> watchLowStockItems(String clinicId);

  // Clinics
  Future<ClinicModel?> getClinic(String clinicId);
  Future<String> addClinic(ClinicModel clinic);
  Future<void> updateClinic(ClinicModel clinic);
  Stream<ClinicModel?> watchClinic(String clinicId);

  // Expenses
  Future<List<ExpenseModel>> getExpenses(String clinicId);
  Future<String> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);

  // Operators
  Future<List<OperatorModel>> getOperators(String clinicId);
  Future<String> addOperator(OperatorModel operator);
  Future<void> updateOperator(OperatorModel operator);
  Future<void> deleteOperator(String operatorId);

  // User Data
  Future<void> updateUserData(String userId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getUserData(String userId);
  Stream<Map<String, dynamic>?> watchUserData(String userId);
}
