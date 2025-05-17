import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String clinicId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? invoiceNumber;

  ExpenseModel({
    required this.id,
    required this.clinicId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
    this.updatedAt,
    this.invoiceNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicId': clinicId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'invoiceNumber': invoiceNumber,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      clinicId: json['clinicId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: (json['date'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      invoiceNumber: json['invoiceNumber'] as String?,
    );
  }
}
