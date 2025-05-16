import 'package:clinic_app/core/constants/validation_constants.dart';
import 'package:clinic_app/core/constants/error_messages.dart';

class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.emailRegex).hasMatch(value)) {
      return ErrorMessages.invalidEmailFormat;
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (value.length < ValidationConstants.minPasswordLength) {
      return ErrorMessages.invalidPassword;
    }
    if (!RegExp(ValidationConstants.passwordRegex).hasMatch(value)) {
      return ErrorMessages.invalidPassword;
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (value.length < ValidationConstants.minNameLength ||
        value.length > ValidationConstants.maxNameLength) {
      return ErrorMessages.invalidName;
    }
    if (!RegExp(ValidationConstants.nameRegex).hasMatch(value)) {
      return ErrorMessages.invalidName;
    }
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.phoneRegex).hasMatch(value)) {
      return ErrorMessages.invalidPhone;
    }
    return null;
  }

  // TC Kimlik No validation
  static String? validateTCKimlik(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.tcKimlikRegex).hasMatch(value)) {
      return ErrorMessages.invalidTCKimlik;
    }
    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.dateRegex).hasMatch(value)) {
      return ErrorMessages.invalidDate;
    }
    return null;
  }

  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.timeRegex).hasMatch(value)) {
      return ErrorMessages.invalidTime;
    }
    return null;
  }

  // URL validation
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.urlRegex).hasMatch(value)) {
      return ErrorMessages.invalidURL;
    }
    return null;
  }

  // Currency validation
  static String? validateCurrency(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.currencyRegex).hasMatch(value)) {
      return ErrorMessages.invalidCurrency;
    }
    return null;
  }

  // Postal code validation
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (!RegExp(ValidationConstants.postalCodeRegex).hasMatch(value)) {
      return ErrorMessages.invalidPostalCode;
    }
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (value.length < ValidationConstants.minAddressLength ||
        value.length > ValidationConstants.maxAddressLength) {
      return ErrorMessages.invalidAddress;
    }
    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (value != password) {
      return ErrorMessages.passwordMismatch;
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  // Number range validation
  static String? validateNumberRange(
    String? value,
    double min,
    double max,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    try {
      final number = double.parse(value);
      if (number < min || number > max) {
        return '$fieldName must be between $min and $max.';
      }
    } catch (e) {
      return 'Please enter a valid number.';
    }
    return null;
  }

  // Text length validation
  static String? validateTextLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.requiredField;
    }
    if (value.length < minLength || value.length > maxLength) {
      return '$fieldName must be between $minLength and $maxLength characters.';
    }
    return null;
  }
}
