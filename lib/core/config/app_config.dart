class AppConfig {
  static const String appName = 'Clinic App';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String clinicsCollection = 'clinics';
  static const String proceduresCollection = 'procedures';
  static const String stockCollection = 'stock';

  // User Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleClinicOwner = 'clinic_owner';
  static const String rolePatient = 'patient';

  // Cache Keys
  static const String userCacheKey = 'user_cache';
  static const String themeCacheKey = 'theme_cache';
}
