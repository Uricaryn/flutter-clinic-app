class AdminStats {
  final int totalClinics;
  final int activeClinics;
  final int totalUsers;
  final int totalAppointments;

  AdminStats({
    required this.totalClinics,
    required this.activeClinics,
    required this.totalUsers,
    required this.totalAppointments,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalClinics: json['totalClinics'] ?? 0,
      activeClinics: json['activeClinics'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalClinics': totalClinics,
      'activeClinics': activeClinics,
      'totalUsers': totalUsers,
      'totalAppointments': totalAppointments,
    };
  }
}
