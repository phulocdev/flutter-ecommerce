import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category; // Assuming category is an ID
  final String brand;
  final String status;
  final double basePrice;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
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
  });

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(basePrice);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String? ?? 'No Description',
      imageUrl: json['imageUrl'] as String? ?? '',
      category:
          json['category'] as String, // Assuming category is a string ID
      brand: json['brand'] as String,
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
}
