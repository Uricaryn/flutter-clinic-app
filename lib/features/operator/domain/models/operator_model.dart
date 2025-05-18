import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorModel {
  final String id;
  final String clinicId;
  final String name;
  final String email;
  final String phone;
  final String role; // örn: sekreter, doktor, hemşire
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool temporaryPassword;

  OperatorModel({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.temporaryPassword = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicId': clinicId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEmailVerified': isEmailVerified,
      'temporaryPassword': temporaryPassword,
    };
  }

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as String,
      clinicId: json['clinicId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      temporaryPassword: json['temporaryPassword'] as bool? ?? false,
    );
  }

  OperatorModel copyWith({
    String? id,
    String? clinicId,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? temporaryPassword,
  }) {
    return OperatorModel(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      temporaryPassword: temporaryPassword ?? this.temporaryPassword,
    );
  }
}
 