import 'package:intl/intl.dart';

class Product {
  final String _id; // Use _id here to match your backend response
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String brand;
  final String status;
  final double basePrice;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required String id, // You can alias this field for easier use
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.status,
    required this.basePrice,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : _id = id;

  String get id => _id; // Getter for id to be used in the navigation

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(basePrice);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String, // Mapping _id from backend response
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String? ?? 'No Description',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] is String
          ? json['category']
          : (json['category'] as Map<String, dynamic>)['_id'] ?? '',
      brand: json['brand'] is String
          ? json['brand']
          : (json['brand'] as Map<String, dynamic>)['_id'] ?? '',
      status: json['status'] as String,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isDeleted: json['isDeleted'] as bool,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'status': status,
      'basePrice': basePrice,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
