class ProcedureModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String clinicId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProcedureModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.clinicId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Mock data generator
  static List<ProcedureModel> getMockProcedures() {
    return [
      ProcedureModel(
        id: '1',
        name: 'Dental Cleaning',
        description: 'Professional teeth cleaning and examination',
        price: 150.00,
        durationMinutes: 60,
        clinicId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ProcedureModel(
        id: '2',
        name: 'Eye Examination',
        description: 'Comprehensive eye health check and vision test',
        price: 200.00,
        durationMinutes: 45,
        clinicId: '2',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ProcedureModel(
        id: '3',
        name: 'General Check-up',
        description: 'Complete physical examination and health assessment',
        price: 180.00,
        durationMinutes: 90,
        clinicId: '3',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'clinicId': clinicId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    return ProcedureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      clinicId: json['clinicId'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
