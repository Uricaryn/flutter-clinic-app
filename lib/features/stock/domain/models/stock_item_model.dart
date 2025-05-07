class StockItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String unit;
  final int minimumQuantity;
  final String clinicId;
  final DateTime lastRestocked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StockItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.minimumQuantity,
    required this.clinicId,
    required this.lastRestocked,
    required this.createdAt,
    this.updatedAt,
  });

  // Mock data generator
  static List<StockItemModel> getMockStockItems() {
    return [
      StockItemModel(
        id: '1',
        name: 'Disposable Gloves',
        description: 'Latex-free medical gloves, box of 100',
        price: 15.99,
        quantity: 50,
        unit: 'boxes',
        minimumQuantity: 10,
        clinicId: '1',
        lastRestocked: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      StockItemModel(
        id: '2',
        name: 'Face Masks',
        description: 'Surgical face masks, box of 50',
        price: 12.99,
        quantity: 25,
        unit: 'boxes',
        minimumQuantity: 5,
        clinicId: '1',
        lastRestocked: DateTime.now().subtract(const Duration(days: 14)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      StockItemModel(
        id: '3',
        name: 'Antiseptic Solution',
        description: '500ml bottle of antiseptic solution',
        price: 8.99,
        quantity: 15,
        unit: 'bottles',
        minimumQuantity: 5,
        clinicId: '1',
        lastRestocked: DateTime.now().subtract(const Duration(days: 21)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
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
      'quantity': quantity,
      'unit': unit,
      'minimumQuantity': minimumQuantity,
      'clinicId': clinicId,
      'lastRestocked': lastRestocked.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      minimumQuantity: json['minimumQuantity'] as int,
      clinicId: json['clinicId'] as String,
      lastRestocked: DateTime.parse(json['lastRestocked'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  bool get needsRestock => quantity <= minimumQuantity;
}
