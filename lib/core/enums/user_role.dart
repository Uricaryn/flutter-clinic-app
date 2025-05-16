enum UserRole {
  operator('operator', 'Operatör'),
  clinicAdmin('clinic_admin', 'Klinik Yetkilisi'),
  superAdmin('super_admin', 'Süper Admin');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.operator,
    );
  }

  bool get isClinicAdmin => this == UserRole.clinicAdmin;
  bool get isSuperAdmin => this == UserRole.superAdmin;
  bool get isOperator => this == UserRole.operator;

  // Yetki kontrolleri
  bool get canAccessAdminPanel => isSuperAdmin;
  bool get canManageClinic => isClinicAdmin || isSuperAdmin;
  bool get canManageOperators => isClinicAdmin;
  bool get canViewClinicData => isClinicAdmin || isOperator;
  bool get canViewAllData => isSuperAdmin;

  static List<UserRole> get staffRoles => [UserRole.operator];
  static List<UserRole> get adminRoles =>
      [UserRole.clinicAdmin, UserRole.superAdmin];
}
