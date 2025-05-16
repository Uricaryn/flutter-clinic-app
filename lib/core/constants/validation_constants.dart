class ValidationConstants {
  // Password validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const String passwordRegex =
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{6,}$';

  // Name validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const String nameRegex = r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]{2,50}$';

  // Phone number validation
  static const String phoneRegex = r'^\+?[0-9]{10,15}$';

  // Email validation
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // TC Kimlik No validation
  static const String tcKimlikRegex = r'^[1-9][0-9]{10}$';

  // Date validation
  static const String dateRegex = r'^\d{4}-\d{2}-\d{2}$';

  // Time validation
  static const String timeRegex = r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$';

  // URL validation
  static const String urlRegex =
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';

  // Currency validation
  static const String currencyRegex = r'^\d+(\.\d{1,2})?$';

  // Postal code validation
  static const String postalCodeRegex = r'^\d{5}$';

  // Address validation
  static const int minAddressLength = 10;
  static const int maxAddressLength = 200;
}
