import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String patientPhone;
  final String procedureId;
  final String procedureName;
  final String operatorId;
  final String operatorName;
  final DateTime dateTime;
  final String status;
  final String? notes;
  final String clinicId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? paymentAmount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? paymentNote;
  final List<Map<String, dynamic>>? usedStockItems;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.procedureId,
    required this.procedureName,
    required this.operatorId,
    required this.operatorName,
    required this.dateTime,
    required this.status,
    this.notes,
    required this.clinicId,
    required this.createdAt,
    this.updatedAt,
    this.paymentAmount,
    this.paymentDate,
    this.paymentMethod,
    this.paymentNote,
    this.usedStockItems,
  });

  // Mock data generator
  static List<AppointmentModel> getMockAppointments() {
    return [
      AppointmentModel(
        id: '1',
        patientId: 'patient1',
        patientName: 'John Doe',
        patientPhone: '555-1234',
        procedureId: '1',
        procedureName: 'Dental Cleaning',
        operatorId: 'doctor1',
        operatorName: 'Dr. John Doe',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        status: 'scheduled',
        notes: 'Regular check-up',
        clinicId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AppointmentModel(
        id: '2',
        patientId: 'patient2',
        patientName: 'Jane Smith',
        patientPhone: '555-5678',
        procedureId: '2',
        procedureName: 'Eye Examination',
        operatorId: 'doctor2',
        operatorName: 'Dr. Jane Smith',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        status: 'confirmed',
        notes: 'Annual eye check-up',
        clinicId: '2',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AppointmentModel(
        id: '3',
        patientId: 'patient3',
        patientName: 'Mike Johnson',
        patientPhone: '555-9012',
        procedureId: '3',
        procedureName: 'General Check-up',
        operatorId: 'doctor3',
        operatorName: 'Dr. Mike Johnson',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        status: 'scheduled',
        notes: 'Routine health check',
        clinicId: '3',
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
      'patientPhone': patientPhone,
      'procedureId': procedureId,
      'procedureName': procedureName,
      'operatorId': operatorId,
      'operatorName': operatorName,
      'dateTime': dateTime,
      'status': status,
      'notes': notes,
      'clinicId': clinicId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'paymentAmount': paymentAmount,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'paymentNote': paymentNote,
      'usedStockItems': usedStockItems,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientPhone: json['patientPhone'] as String,
      procedureId: json['procedureId'] as String,
      procedureName: json['procedureName'] as String? ?? 'İşlem',
      operatorId: json['operatorId'] as String,
      operatorName: json['operatorName'] as String? ?? 'Doktor',
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
      clinicId: json['clinicId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      paymentAmount: json['paymentAmount'] != null
          ? (json['paymentAmount'] as num).toDouble()
          : null,
      paymentDate: json['paymentDate'] != null
          ? (json['paymentDate'] as Timestamp).toDate()
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      paymentNote: json['paymentNote'] as String?,
      usedStockItems: json['usedStockItems'] != null
          ? List<Map<String, dynamic>>.from(json['usedStockItems'])
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
