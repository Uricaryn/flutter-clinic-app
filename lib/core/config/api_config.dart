import 'package:flutter/foundation.dart';

/// API configuration for PostgreSQL backend
///
/// This configures the REST API and WebSocket endpoints
/// for the PostgreSQL backend.

class ApiConfig {
  ApiConfig._();

  /// Base URL for REST API
  ///
  /// Development: localhost
  /// Production: your deployed backend URL
  static String get baseUrl {
    if (kReleaseMode) {
      // Production URL - Update this when deploying
      return _productionBaseUrl;
    } else if (kProfileMode) {
      // Profile mode - can use staging
      return _stagingBaseUrl;
    } else {
      // Debug mode - local development
      return _developmentBaseUrl;
    }
  }

  /// WebSocket URL for realtime updates
  static String get wsUrl {
    if (kReleaseMode) {
      return _productionWsUrl;
    } else if (kProfileMode) {
      return _stagingWsUrl;
    } else {
      return _developmentWsUrl;
    }
  }

  // Development URLs (localhost)
  static const String _developmentBaseUrl = 'http://localhost:3000/api';
  static const String _developmentWsUrl = 'ws://localhost:3000/ws';

  // Staging URLs (optional)
  static const String _stagingBaseUrl =
      'https://staging-api.your-domain.com/api';
  static const String _stagingWsUrl = 'wss://staging-api.your-domain.com/ws';

  // Production URLs (update when deploying)
  static const String _productionBaseUrl = 'https://api.your-domain.com/api';
  static const String _productionWsUrl = 'wss://api.your-domain.com/ws';

  // API endpoints
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';

  static const String usersEndpoint = '/users';
  static const String clinicsEndpoint = '/clinics';
  static const String patientsEndpoint = '/patients';
  static const String appointmentsEndpoint = '/appointments';
  static const String proceduresEndpoint = '/procedures';
  static const String stockEndpoint = '/stock';
  static const String expensesEndpoint = '/expenses';
  static const String operatorsEndpoint = '/operators';

  // API configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // WebSocket configuration
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 5;

  /// Get full URL for an endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
