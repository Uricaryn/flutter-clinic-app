/// Utility functions for date/time handling with PostgreSQL
class DateTimeUtils {
  /// Parse DateTime from various sources (String or DateTime)
  ///
  /// Supports PostgreSQL ISO string formats
  static DateTime parseDateTime(dynamic value) {
    if (value == null) {
      throw ArgumentError('DateTime value cannot be null');
    }

    if (value is DateTime) {
      return value;
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

  /// Convert DateTime to JSON (ISO8601 string for PostgreSQL)
  static String toJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Convert nullable DateTime to JSON
  static String? toJsonNullable(DateTime? dateTime) {
    if (dateTime == null) return null;
    return toJson(dateTime);
  }
}
