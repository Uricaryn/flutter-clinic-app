import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log user login
  Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }

  // Log user signup
  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }

  // Log appointment creation
  Future<void> logAppointmentCreated({
    required String appointmentId,
    required String clinicId,
    required String procedureId,
  }) async {
    await _analytics.logEvent(
      name: 'appointment_created',
      parameters: {
        'appointment_id': appointmentId,
        'clinic_id': clinicId,
        'procedure_id': procedureId,
      },
    );
  }

  // Log procedure booking
  Future<void> logProcedureBooked({
    required String procedureId,
    required String clinicId,
  }) async {
    await _analytics.logEvent(
      name: 'procedure_booked',
      parameters: {
        'procedure_id': procedureId,
        'clinic_id': clinicId,
      },
    );
  }

  // Log stock update
  Future<void> logStockUpdated({
    required String itemId,
    required String clinicId,
    required int quantity,
  }) async {
    await _analytics.logEvent(
      name: 'stock_updated',
      parameters: {
        'item_id': itemId,
        'clinic_id': clinicId,
        'quantity': quantity,
      },
    );
  }

  // Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Log user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
  }
}
