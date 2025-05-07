import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  doctor,
  nurse,
  receptionist,
  patient,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final String? clinicId;
  final String? clinicName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    this.clinicId,
    this.clinicName,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  // Mock data generator
  static List<UserModel> getMockUsers() {
    return [
      UserModel(
        id: '1',
        name: 'Dr. John Smith',
        email: 'john.smith@clinic.com',
        phone: '+1 234 567 8900',
        role: UserRole.doctor,
        clinicId: '1',
        clinicName: 'Dental Care Plus',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      UserModel(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.j@clinic.com',
        phone: '+1 234 567 8901',
        role: UserRole.nurse,
        clinicId: '1',
        clinicName: 'Dental Care Plus',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      UserModel(
        id: '3',
        name: 'Admin User',
        email: 'admin@clinic.com',
        phone: '+1 234 567 8902',
        role: UserRole.admin,
        createdAt: DateTime.now().subtract(const Duration(days: 730)),
      ),
    ];
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role.toString().split('.').last,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.patient,
      ),
      clinicId: json['clinicId'] as String?,
      clinicName: json['clinicName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      lastLogin: json['lastLogin'] != null
          ? (json['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }
}
