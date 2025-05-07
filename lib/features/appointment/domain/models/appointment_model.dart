enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
  noShow,
}

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String clinicId;
  final String clinicName;
  final String procedureId;
  final String procedureName;
  final DateTime dateTime;
  final int durationMinutes;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.clinicId,
    required this.clinicName,
    required this.procedureId,
    required this.procedureName,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Mock data generator
  static List<AppointmentModel> getMockAppointments() {
    return [
      AppointmentModel(
        id: '1',
        patientId: 'patient1',
        patientName: 'John Doe',
        clinicId: '1',
        clinicName: 'Dental Care Plus',
        procedureId: '1',
        procedureName: 'Dental Cleaning',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        durationMinutes: 60,
        status: AppointmentStatus.scheduled,
        notes: 'Regular check-up',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AppointmentModel(
        id: '2',
        patientId: 'patient2',
        patientName: 'Jane Smith',
        clinicId: '2',
        clinicName: 'Eye Care Center',
        procedureId: '2',
        procedureName: 'Eye Examination',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        durationMinutes: 45,
        status: AppointmentStatus.confirmed,
        notes: 'Annual eye check-up',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AppointmentModel(
        id: '3',
        patientId: 'patient3',
        patientName: 'Mike Johnson',
        clinicId: '3',
        clinicName: 'Family Medical Clinic',
        procedureId: '3',
        procedureName: 'General Check-up',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        durationMinutes: 90,
        status: AppointmentStatus.scheduled,
        notes: 'Routine health check',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'procedureId': procedureId,
      'procedureName': procedureName,
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      clinicId: json['clinicId'] as String,
      clinicName: json['clinicName'] as String,
      procedureId: json['procedureId'] as String,
      procedureName: json['procedureName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isToday =>
      dateTime.year == DateTime.now().year &&
      dateTime.month == DateTime.now().month &&
      dateTime.day == DateTime.now().day;
}
