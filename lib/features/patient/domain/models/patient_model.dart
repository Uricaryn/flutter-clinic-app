import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final DateTime dateOfBirth;
  final String gender;
  final String notes;
  final String clinicId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PatientModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.notes,
    required this.clinicId,
    required this.createdAt,
    this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      dateOfBirth: (json['dateOfBirth'] as Timestamp).toDate(),
      gender: json['gender'] as String,
      notes: json['notes'] as String,
      clinicId: json['clinicId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'notes': notes,
      'clinicId': clinicId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
