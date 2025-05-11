import 'package:flutter_ecommerce/models/dto/create_sku_dto.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final double basePrice;
  final int minStockLevel;
  final int maxStockLevel;
  final List<String>? attributeNames;
  final List<Sku>? skus;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.basePrice,
    required this.minStockLevel,
    required this.maxStockLevel,
    this.attributeNames,
    this.skus,
    this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    double? basePrice,
    int? minStockLevel,
    int? maxStockLevel,
    List<String>? attributeNames,
    List<Sku>? skus,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      basePrice: basePrice ?? this.basePrice,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      attributeNames: attributeNames ?? this.attributeNames,
      skus: skus ?? this.skus,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  String get formattedPrice => '\$${basePrice.toStringAsFixed(2)}';
}
