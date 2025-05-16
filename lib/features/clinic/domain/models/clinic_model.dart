import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  final String id;
  final String name;
  final String specialization;
  final String address;
  final String phone;
  final String email;
  final bool isActive;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? patientIds;
  final List<String>? operatorIds;
  final String? clinicPhoneCountryCode;
  final String? clinicPhoneNumber;

  ClinicModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.address,
    required this.phone,
    required this.email,
    required this.isActive,
    this.ownerId,
    DateTime? createdAt,
    required this.updatedAt,
    this.patientIds,
    this.operatorIds,
    this.clinicPhoneCountryCode,
    this.clinicPhoneNumber,
  }) : createdAt = createdAt ?? DateTime.now();

  // Mock data generator
  static List<ClinicModel> getMockClinics() {
    return [
      ClinicModel(
        id: '1',
        name: 'Dental Clinic',
        specialization: 'Dentistry',
        address: '123 Main St',
        phone: '+1234567890',
        email: 'dental@example.com',
        isActive: true,
        ownerId: 'owner1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ClinicModel(
        id: '2',
        name: 'Eye Clinic',
        specialization: 'Ophthalmology',
        address: '456 Oak St',
        phone: '+0987654321',
        email: 'eye@example.com',
        isActive: true,
        ownerId: 'owner2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ClinicModel(
        id: '3',
        name: 'General Clinic',
        specialization: 'General Medicine',
        address: '789 Pine St',
        phone: '+1122334455',
        email: 'general@example.com',
        isActive: false,
        ownerId: 'owner3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'ownerId': ownerId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'patientIds': patientIds ?? [],
      'operatorIds': operatorIds ?? [],
      'clinicPhoneCountryCode': clinicPhoneCountryCode ?? '+90',
      'clinicPhoneNumber': clinicPhoneNumber ?? '',
    };
  }

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      ownerId: json['ownerId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      patientIds: (json['patientIds'] as List<dynamic>?)?.cast<String>(),
      operatorIds: (json['operatorIds'] as List<dynamic>?)?.cast<String>(),
      clinicPhoneCountryCode:
          json['clinicPhoneCountryCode'] as String? ?? '+90',
      clinicPhoneNumber: json['clinicPhoneNumber'] as String? ?? '',
    );
  }

  ClinicModel copyWith({
    String? id,
    String? name,
    String? specialization,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? patientIds,
    List<String>? operatorIds,
    String? clinicPhoneCountryCode,
    String? clinicPhoneNumber,
  }) {
    return ClinicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientIds: patientIds ?? this.patientIds,
      operatorIds: operatorIds ?? this.operatorIds,
      clinicPhoneCountryCode:
          clinicPhoneCountryCode ?? this.clinicPhoneCountryCode,
      clinicPhoneNumber: clinicPhoneNumber ?? this.clinicPhoneNumber,
    );
  }
}
