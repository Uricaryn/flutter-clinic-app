import 'dart:async';
import 'package:clinic_app/core/services/database_service.dart';
import 'package:clinic_app/core/services/api_service.dart';
import 'package:clinic_app/core/services/flutter_websocket_service.dart';
import 'package:clinic_app/core/config/api_config.dart';
import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';
import 'package:clinic_app/features/patient/domain/models/patient_model.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/stock/domain/models/stock_item_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/clinic/domain/models/expense_model.dart';
import 'package:clinic_app/features/operator/domain/models/operator_model.dart';

/// PostgreSQL database service implementation using REST API
/// 
/// This service communicates with the Node.js backend and uses
/// WebSocket for realtime updates.
class PostgresqlDatabaseService implements DatabaseService {
  final ApiService _api = ApiService();
  final FlutterWebSocketService _ws = FlutterWebSocketService();
  
  // Stream controllers for realtime data
  final Map<String, StreamController<List<dynamic>>> _streamControllers = {};

  PostgresqlDatabaseService() {
    _initializeWebSocket();
  }

  /// Initialize WebSocket connection and listeners
  void _initializeWebSocket() {
    _ws.connect();
    
    // Listen to WebSocket messages
    _ws.messages.listen((message) {
      if (message['type'] == 'update') {
        final collection = message['collection'] as String;
        final action = message['action'] as String;
        final data = message['data'];
        
        _handleRealtimeUpdate(collection, action, data);
      }
    });
  }

  /// Handle realtime updates from WebSocket
  void _handleRealtimeUpdate(String collection, String action, dynamic data) {
    if (_streamControllers.containsKey(collection)) {
      // Trigger stream refresh by emitting update signal
      // The stream will refetch data from the API
      _streamControllers[collection]?.add([]);
    }
  }

  /// Get or create stream controller for a collection
  StreamController<List<T>> _getStreamController<T>(String collectionKey) {
    if (!_streamControllers.containsKey(collectionKey)) {
      _streamControllers[collectionKey] = StreamController<List<dynamic>>.broadcast();
    }
    return _streamControllers[collectionKey] as StreamController<List<T>>;
  }

  // ============================================================================
  // APPOINTMENTS
  // ============================================================================

  @override
  Future<List<AppointmentModel>> getAppointments(String clinicId) async {
    final response = await _api.get(
      ApiConfig.appointmentsEndpoint,
      queryParameters: {'clinicId': clinicId},
    );
    
    final List data = response.data['appointments'] ?? [];
    return data.map((json) => AppointmentModel.fromJson(json)).toList();
  }

  @override
  Future<AppointmentModel> getAppointment(String appointmentId) async {
    final response = await _api.get('${ApiConfig.appointmentsEndpoint}/$appointmentId');
    return AppointmentModel.fromJson(response.data['appointment']);
  }

  @override
  Future<String> addAppointment(AppointmentModel appointment) async {
    final response = await _api.post(
      ApiConfig.appointmentsEndpoint,
      data: appointment.toJson(),
    );
    return response.data['appointment']['id'] as String;
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _api.put(
      '${ApiConfig.appointmentsEndpoint}/${appointment.id}',
      data: appointment.toJson(),
    );
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    await _api.delete('${ApiConfig.appointmentsEndpoint}/$appointmentId');
  }

  @override
  Stream<List<AppointmentModel>> watchAppointments(String clinicId) async* {
    // Subscribe to WebSocket updates
    _ws.subscribe('appointments');
    
    final controller = _getStreamController<AppointmentModel>('appointments_$clinicId');
    
    // Initial data fetch
    yield await getAppointments(clinicId);
    
    // Listen for updates
    await for (final _ in controller.stream) {
      yield await getAppointments(clinicId);
    }
  }

  @override
  Stream<List<AppointmentModel>> watchUpcomingAppointments(String clinicId) async* {
    _ws.subscribe('appointments');
    
    final controller = _getStreamController<AppointmentModel>('appointments_upcoming_$clinicId');
    
    // Fetch upcoming appointments
    final fetch = () async {
      final response = await _api.get(
        '${ApiConfig.appointmentsEndpoint}/upcoming',
        queryParameters: {'clinicId': clinicId},
      );
      
      final List data = response.data['appointments'] ?? [];
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    };
    
    yield await fetch();
    
    await for (final _ in controller.stream) {
      yield await fetch();
    }
  }

  // ============================================================================
  // PATIENTS
  // ============================================================================

  @override
  Future<List<PatientModel>> getPatients(String clinicId) async {
    final response = await _api.get(
      ApiConfig.patientsEndpoint,
      queryParameters: {'clinicId': clinicId},
    );
    
    final List data = response.data['patients'] ?? [];
    return data.map((json) => PatientModel.fromJson(json)).toList();
  }

  @override
  Future<PatientModel> getPatient(String patientId) async {
    final response = await _api.get('${ApiConfig.patientsEndpoint}/$patientId');
    return PatientModel.fromJson(response.data['patient']);
  }

  @override
  Future<String> addPatient(PatientModel patient) async {
    final response = await _api.post(
      ApiConfig.patientsEndpoint,
      data: patient.toJson(),
    );
    return response.data['patient']['id'] as String;
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    await _api.put(
      '${ApiConfig.patientsEndpoint}/${patient.id}',
      data: patient.toJson(),
    );
  }

  @override
  Future<void> deletePatient(String patientId, String clinicId) async {
    await _api.delete('${ApiConfig.patientsEndpoint}/$patientId');
  }

  @override
  Stream<List<PatientModel>> watchPatients(String clinicId) async* {
    _ws.subscribe('patients');
    
    final controller = _getStreamController<PatientModel>('patients_$clinicId');
    
    yield await getPatients(clinicId);
    
    await for (final _ in controller.stream) {
      yield await getPatients(clinicId);
    }
  }

  @override
  Future<List<PatientModel>> searchPatients(String clinicId, String query) async {
    final response = await _api.get(
      '${ApiConfig.patientsEndpoint}/search',
      queryParameters: {
        'clinicId': clinicId,
        'query': query,
      },
    );
    
    final List data = response.data['patients'] ?? [];
    return data.map((json) => PatientModel.fromJson(json)).toList();
  }

  // ============================================================================
  // PROCEDURES
  // ============================================================================

  @override
  Future<List<ProcedureModel>> getProcedures(String clinicId) async {
    final response = await _api.get(
      ApiConfig.proceduresEndpoint,
      queryParameters: {'clinicId': clinicId},
    );
    
    final List data = response.data['procedures'] ?? [];
    return data.map((json) => ProcedureModel.fromJson(json)).toList();
  }

  @override
  Future<ProcedureModel> getProcedure(String procedureId) async {
    final response = await _api.get('${ApiConfig.proceduresEndpoint}/$procedureId');
    return ProcedureModel.fromJson(response.data['procedure']);
  }

  @override
  Future<String> addProcedure(ProcedureModel procedure) async {
    final response = await _api.post(
      ApiConfig.proceduresEndpoint,
      data: procedure.toJson(),
    );
    return response.data['procedure']['id'] as String;
  }

  @override
  Future<void> updateProcedure(ProcedureModel procedure) async {
    await _api.put(
      '${ApiConfig.proceduresEndpoint}/${procedure.id}',
      data: procedure.toJson(),
    );
  }

  @override
  Future<void> deleteProcedure(String procedureId) async {
    await _api.delete('${ApiConfig.proceduresEndpoint}/$procedureId');
  }

  @override
  Stream<List<ProcedureModel>> watchProcedures(String clinicId) async* {
    _ws.subscribe('procedures');
    
    final controller = _getStreamController<ProcedureModel>('procedures_$clinicId');
    
    yield await getProcedures(clinicId);
    
    await for (final _ in controller.stream) {
      yield await getProcedures(clinicId);
    }
  }

  // ============================================================================
  // STOCK ITEMS
  // ============================================================================

  @override
  Future<List<StockItemModel>> getStockItems(String clinicId) async {
    final response = await _api.get(
      ApiConfig.stockEndpoint,
      queryParameters: {'clinicId': clinicId},
    );
    
    final List data = response.data['stockItems'] ?? [];
    return data.map((json) => StockItemModel.fromJson(json)).toList();
  }

  @override
  Future<StockItemModel> getStockItem(String stockItemId) async {
    final response = await _api.get('${ApiConfig.stockEndpoint}/$stockItemId');
    return StockItemModel.fromJson(response.data['stockItem']);
  }

  @override
  Future<String> addStockItem(StockItemModel stockItem) async {
    final response = await _api.post(
      ApiConfig.stockEndpoint,
      data: stockItem.toJson(),
    );
    return response.data['stockItem']['id'] as String;
  }

  @override
  Future<void> updateStockItem(StockItemModel stockItem) async {
    await _api.put(
      '${ApiConfig.stockEndpoint}/${stockItem.id}',
      data: stockItem.toJson(),
    );
  }

  @override
  Future<void> deleteStockItem(String stockItemId) async {
    await _api.delete('${ApiConfig.stockEndpoint}/$stockItemId');
  }

  @override
  Stream<List<StockItemModel>> watchStockItems(String clinicId) async* {
    _ws.subscribe('stock_items');
    
    final controller = _getStreamController<StockItemModel>('stock_items_$clinicId');
    
    yield await getStockItems(clinicId);
    
    await for (final _ in controller.stream) {
      yield await getStockItems(clinicId);
    }
  }

  @override
  Stream<List<StockItemModel>> watchLowStockItems(String clinicId) async* {
    _ws.subscribe('stock_items');
    
    final controller = _getStreamController<StockItemModel>('stock_items_low_$clinicId');
    
    final fetch = () async {
      final response = await _api.get(
        '${ApiConfig.stockEndpoint}/low-stock',
        queryParameters: {'clinicId': clinicId},
      );
      
      final List data = response.data['stockItems'] ?? [];
      return data.map((json) => StockItemModel.fromJson(json)).toList();
    };
    
    yield await fetch();
    
    await for (final _ in controller.stream) {
      yield await fetch();
    }
  }

  // ============================================================================
  // CLINICS
  // ============================================================================

  @override
  Future<ClinicModel?> getClinic(String clinicId) async {
    try {
      final response = await _api.get('${ApiConfig.clinicsEndpoint}/$clinicId');
      return ClinicModel.fromJson(response.data['clinic']);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> addClinic(ClinicModel clinic) async {
    final response = await _api.post(
      ApiConfig.clinicsEndpoint,
      data: clinic.toJson(),
    );
    return response.data['clinic']['id'] as String;
  }

  @override
  Future<void> updateClinic(ClinicModel clinic) async {
    await _api.put(
      '${ApiConfig.clinicsEndpoint}/${clinic.id}',
      data: clinic.toJson(),
    );
  }

  @override
  Stream<ClinicModel?> watchClinic(String clinicId) async* {
    _ws.subscribe('clinics');
    
    final controller = _getStreamController<ClinicModel>('clinic_$clinicId');
    
    yield await getClinic(clinicId);
    
    await for (final _ in controller.stream) {
      yield await getClinic(clinicId);
    }
  }

  // ============================================================================
  // EXPENSES
  // ============================================================================

  @override
  Future<List<ExpenseModel>> getExpenses(String clinicId) async {
    final response = await _api.get(
      ApiConfig.expensesEndpoint,
      queryParameters: {'clinicId': clinicId},
    );
    
    final List data = response.data['expenses'] ?? [];
    return data.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<String> addExpense(ExpenseModel expense) async {
    final response = await _api.post(
      ApiConfig.expensesEndpoint,
      data: expense.toJson(),
    );
    return response.data['expense']['id'] as String;
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _api.put(
      '${ApiConfig.expensesEndpoint}/${expense.id}',
      data: expense.toJson(),
    );
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _api.delete('${ApiConfig.expensesEndpoint}/$expenseId');
  }

  // ============================================================================
  // OPERATORS
  // ============================================================================

  @override
  Future<List<OperatorModel>> getOperators(String clinicId) async {
    final response = await _api.get(
      ApiConfig.operatorsEndpoint,
      queryParameters: {'clinicId': clinicId},
    );
    
    final List data = response.data['operators'] ?? [];
    return data.map((json) => OperatorModel.fromJson(json)).toList();
  }

  @override
  Future<String> addOperator(OperatorModel operator) async {
    final response = await _api.post(
      ApiConfig.operatorsEndpoint,
      data: operator.toJson(),
    );
    return response.data['operator']['id'] as String;
  }

  @override
  Future<void> updateOperator(OperatorModel operator) async {
    await _api.put(
      '${ApiConfig.operatorsEndpoint}/${operator.id}',
      data: operator.toJson(),
    );
  }

  @override
  Future<void> deleteOperator(String operatorId) async {
    await _api.delete('${ApiConfig.operatorsEndpoint}/$operatorId');
  }

  // ============================================================================
  // USER DATA
  // ============================================================================

  @override
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _api.put('${ApiConfig.usersEndpoint}/$userId', data: data);
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final response = await _api.get('${ApiConfig.usersEndpoint}/$userId');
      return response.data['user'] as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchUserData(String userId) async* {
    final controller = _getStreamController<Map<String, dynamic>>('user_$userId');
    
    yield await getUserData(userId);
    
    await for (final _ in controller.stream) {
      yield await getUserData(userId);
    }
  }

  /// Dispose resources
  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    _ws.dispose();
  }
}
