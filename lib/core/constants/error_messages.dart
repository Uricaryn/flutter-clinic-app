class ErrorMessages {
  // Authentication Errors
  static const String userNotFound = 'No user found with this email.';
  static const String wrongPassword = 'Wrong password provided.';
  static const String emailAlreadyInUse =
      'The email address is already in use.';
  static const String invalidEmail = 'The email address is invalid.';
  static const String operationNotAllowed =
      'Email/password accounts are not enabled.';
  static const String weakPassword = 'The password is too weak.';
  static const String userDisabled = 'This user has been disabled.';
  static const String tooManyRequests =
      'Too many attempts. Please try again later.';
  static const String emailNotVerified =
      'Please verify your email address first.';
  static const String invalidVerificationCode = 'Invalid verification code.';
  static const String sessionExpired =
      'Your session has expired. Please sign in again.';
  static const String registrationSuccess =
      'Registration successful! Please verify your email.';

  // Validation Errors
  static const String requiredField = 'This field is required.';
  static const String invalidName =
      'Please enter a valid name (2-50 characters, letters only).';
  static const String invalidEmailFormat =
      'Please enter a valid email address.';
  static const String invalidPassword =
      'Password must be at least 6 characters and contain both letters and numbers.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String invalidTCKimlik = 'Please enter a valid TC Kimlik No.';
  static const String invalidDate = 'Please enter a valid date (YYYY-MM-DD).';
  static const String invalidTime = 'Please enter a valid time (HH:MM).';
  static const String invalidURL = 'Please enter a valid URL.';
  static const String invalidCurrency = 'Please enter a valid amount.';
  static const String invalidPostalCode =
      'Please enter a valid postal code (5 digits).';
  static const String invalidAddress =
      'Address must be between 10 and 200 characters.';

  // Network Errors
  static const String noInternetConnection =
      'No internet connection. Please check your connection and try again.';
  static const String connectionTimeout =
      'Connection timeout. Please try again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError =
      'An unexpected error occurred. Please try again.';

  // Permission Errors
  static const String cameraPermissionDenied =
      'Camera permission is required to take photos.';
  static const String galleryPermissionDenied =
      'Gallery permission is required to select photos.';
  static const String locationPermissionDenied =
      'Location permission is required for this feature.';
  static const String notificationPermissionDenied =
      'Notification permission is required for this feature.';

  // File Errors
  static const String fileTooLarge =
      'File size is too large. Maximum size is 5MB.';
  static const String invalidFileType =
      'Invalid file type. Please select a valid file.';
  static const String fileUploadFailed =
      'Failed to upload file. Please try again.';

  // Appointment Errors
  static const String appointmentNotFound = 'Appointment not found.';
  static const String appointmentAlreadyExists =
      'An appointment already exists at this time.';
  static const String invalidAppointmentTime =
      'Invalid appointment time. Please select a valid time.';
  static const String appointmentCancellationFailed =
      'Failed to cancel appointment. Please try again.';

  // Profile Errors
  static const String profileUpdateFailed =
      'Failed to update profile. Please try again.';
  static const String profileNotFound = 'Profile not found.';
  static const String invalidProfileData =
      'Invalid profile data. Please check your information.';

  // Payment Errors
  static const String paymentFailed = 'Payment failed. Please try again.';
  static const String invalidPaymentMethod = 'Invalid payment method.';
  static const String insufficientFunds = 'Insufficient funds.';
  static const String paymentCancelled = 'Payment was cancelled.';

  // General Errors
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String tryAgainLater = 'Please try again later.';
  static const String invalidInput =
      'Invalid input. Please check your information.';
  static const String sessionTimeout =
      'Your session has timed out. Please sign in again.';
  static const String maintenanceMode =
      'The app is currently under maintenance. Please try again later.';
}
