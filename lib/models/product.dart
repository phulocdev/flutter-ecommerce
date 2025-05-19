import 'package:flutter_ecommerce/models/brand.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/sku.dart';
import 'package:intl/intl.dart';

class Product {
  final String _id;
  final String code;
  final String name;
  final String description;
  final String imageUrl;
  final int? discountPercentage;
  final int? soldQuantity;
  final Category? category;
  final Brand? brand;
  final String status;
  final double basePrice;
  final int minStockLevel;
  final int maxStockLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;
  final List<Sku>? skus;
  final List<AttributeValue>? attributeOptions;

  const Product({
    required String id,
    required this.code,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.category,
    this.soldQuantity,
    this.discountPercentage,
    this.brand,
    required this.status,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.basePrice,
    required this.createdAt,
    required this.updatedAt,
    required this.views,
    this.skus,
    this.attributeOptions,
  }) : _id = id;

  String get id => _id;

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(basePrice);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null,
      brand: json['brand'] is Map<String, dynamic>
          ? Brand.fromJson(json['brand'])
          : null,
      status: json['status'] as String,
      soldQuantity:
          json['soldQuantity'] != null ? json['soldQuantity'] as int : 0,
      discountPercentage: json['discountPercentage'] != null
          ? json['discountPercentage'] as int
          : 0,
      basePrice: (json['basePrice'] as num).toDouble(),
      minStockLevel: (json['minStockLevel'] as num).toInt(),
      maxStockLevel: (json['maxStockLevel'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      views: json['views'] as int,
      skus: json['skus'] != null
          ? (json['skus'] as List<dynamic>).map((e) => Sku.fromJson(e)).toList()
          : null,
      attributeOptions: json['attributeOptions'] != null
          ? (json['attributeOptions'] as List<dynamic>)
              .map((e) => AttributeValue.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': _id,
        'code': code,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'category': category?.toJson(),
        'brand': brand?.toJson(),
        'status': status,
        'soldQuantity': soldQuantity,
        'discountPercentage': discountPercentage,
        'basePrice': basePrice,
        'minStockLevel': minStockLevel,
        'maxStockLevel': maxStockLevel,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'views': views,
        'skus': skus?.map((e) => e.toJson()).toList(),
        'attributeOptions': attributeOptions?.map((e) => e.toJson()).toList(),
      };
}

class AttributeValue {
  final String name;
  final List<String> values;

  AttributeValue({
    required this.name,
    required this.values,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      name: json['name'] as String,
      values: List<String>.from(json['values'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'values': values,
      };
}
