class ClinicModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String specialization;
  final String ownerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.specialization,
    required this.ownerId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Mock data generator
  static List<ClinicModel> getMockClinics() {
    return [
      ClinicModel(
        id: '1',
        name: 'Dental Care Plus',
        address: '123 Health Street, Medical District',
        phone: '+1 234 567 8900',
        email: 'contact@dentalcare.com',
        specialization: 'Dentistry',
        ownerId: 'owner1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ClinicModel(
        id: '2',
        name: 'Eye Care Center',
        address: '456 Vision Road, Healthcare Plaza',
        phone: '+1 234 567 8901',
        email: 'info@eyecare.com',
        specialization: 'Ophthalmology',
        ownerId: 'owner2',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ClinicModel(
        id: '3',
        name: 'Family Medical Clinic',
        address: '789 Wellness Avenue, Health Complex',
        phone: '+1 234 567 8902',
        email: 'contact@familymedical.com',
        specialization: 'General Medicine',
        ownerId: 'owner3',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      specialization: json['specialization'] as String,
      ownerId: json['ownerId'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
