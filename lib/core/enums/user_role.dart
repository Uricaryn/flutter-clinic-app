enum UserRole {
  clinicAdmin('clinic_admin'),
  clinicManager('clinic_manager'),
  operator('operator'),
  doctor('doctor'),
  patient('patient');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.clinicAdmin:
      case UserRole.clinicManager:
        return 'Klinik Yetkilisi';
      case UserRole.operator:
        return 'Sekreter';
      case UserRole.doctor:
        return 'Doktor';
      case UserRole.patient:
        return 'Hasta';
    }
  }

  bool get isClinicAdmin =>
      this == UserRole.clinicAdmin || this == UserRole.clinicManager;
  bool get isOperator => this == UserRole.operator;
  bool get isDoctor => this == UserRole.doctor;
  bool get isPatient => this == UserRole.patient;

  // Yetki kontrolleri
  bool get canAccessAdminPanel => isClinicAdmin;
  bool get canManageClinic => isClinicAdmin;
  bool get canManageOperators => isClinicAdmin;
  bool get canViewClinicData => isClinicAdmin || isOperator;
  bool get canViewAppointments => isClinicAdmin || isOperator || isDoctor;

  // Rol dönüşümü için yardımcı metod
  String get normalizedRole {
    if (this == UserRole.clinicManager) {
      return UserRole.clinicAdmin.value;
    }
    return value;
  }

  static List<UserRole> get staffRoles => [UserRole.operator];
  static List<UserRole> get adminRoles =>
      [UserRole.clinicAdmin, UserRole.doctor];
}
