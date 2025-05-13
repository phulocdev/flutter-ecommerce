import 'package:flutter_ecommerce/models/dto/create_sku_dto.dart';
import 'package:intl/intl.dart';

class CreateProductDto {
  final String name;
  final String description;
  final String category;
  final String brand;
  final double basePrice;
  final int minStockLevel;
  final int maxStockLevel;
  final List<String>? attributeNames;
  final List<CreateSkuDto>? skus;
  final String? imageUrl;

  CreateProductDto({
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

  CreateProductDto copyWith({
    String? name,
    String? description,
    String? category,
    String? brand,
    double? basePrice,
    int? minStockLevel,
    int? maxStockLevel,
    List<String>? attributeNames,
    List<CreateSkuDto>? skus,
    String? imageUrl,
  }) {
    return CreateProductDto(
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

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(basePrice);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'basePrice': basePrice,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'attributeNames': attributeNames,
      'skus': skus?.map((sku) => sku.toJson()).toList(),
      'imageUrl': imageUrl,
    };
  }
}
