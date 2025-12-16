import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility functions for date/time handling across Firebase and PostgreSQL
class DateTimeUtils {
  /// Parse DateTime from various sources (Timestamp, String, or DateTime)
  ///
  /// This supports both Firebase Timestamp and PostgreSQL ISO string formats
  static DateTime parseDateTime(dynamic value) {
    if (value == null) {
      throw ArgumentError('DateTime value cannot be null');
    }

    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw ArgumentError('Unsupported date type: ${value.runtimeType}');
  }

  /// Parse nullable DateTime
  static DateTime? parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    try {
      return parseDateTime(value);
    } catch (e) {
      return null;
    }
  }

  /// Convert DateTime to JSON (supports both backends)
  /// - For Firebase: converts to Timestamp
  /// - For PostgreSQL: converts to ISO8601 string
  static dynamic toJson(DateTime dateTime, {bool useFirestore = false}) {
    if (useFirestore) {
      return Timestamp.fromDate(dateTime);
    }
    return dateTime.toIso8601String();
  }

  /// Convert nullable DateTime to JSON
  static dynamic toJsonNullable(DateTime? dateTime,
      {bool useFirestore = false}) {
    if (dateTime == null) return null;
    return toJson(dateTime, useFirestore: useFirestore);
  }
}

