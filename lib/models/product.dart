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
  // final List<AttributeOption>? attributeOptions;

  const Product({
    required String id,
    required this.code,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.category,
    this.brand,
    required this.status,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.basePrice,
    required this.createdAt,
    required this.updatedAt,
    required this.views,
    required this.skus,
    // this.attributeOptions,
  }) : _id = id;

  String get id => _id;

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(basePrice);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id'] as String;
      final code = json['code'] as String;
      final name = json['name'] as String;
      final description = json['description'] as String;
      final imageUrl = json['imageUrl'] as String;
      final category = json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null;
      final brand = json['brand'] is Map<String, dynamic>
          ? Brand.fromJson(json['brand'])
          : null;
      final status = json['status'] as String;
      final basePrice = (json['basePrice'] as num).toDouble();
      final minStockLevel = (json['minStockLevel'] as num).toInt();
      final maxStockLevel = (json['maxStockLevel'] as num).toInt();
      final createdAt = DateTime.parse(json['createdAt']);
      final updatedAt = DateTime.parse(json['updatedAt']);
      final views = json['views'] as int;
      final skus = json['skus'] != null
          ? (json['skus'] as List<dynamic>).map((e) => Sku.fromJson(e)).toList()
          : null;

      return Product(
        id: id,
        code: code,
        name: name,
        description: description,
        imageUrl: imageUrl,
        category: category,
        brand: brand,
        status: status,
        minStockLevel: minStockLevel,
        maxStockLevel: maxStockLevel,
        basePrice: basePrice,
        createdAt: createdAt,
        updatedAt: updatedAt,
        views: views,
        skus: skus,
      );
    } catch (e, stackTrace) {
      print('❌ Failed to parse Product.fromJson');
      print('🔎 JSON: $json');
      print('⚠️ Error: $e');
      print('🧱 Stack trace: $stackTrace');
      rethrow;
    }
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
        'basePrice': basePrice,
        'minStockLevel': minStockLevel,
        'maxStockLevel': maxStockLevel,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'views': views,
        'skus': skus?.map((e) => e.toJson()).toList(),
        // 'attributeOptions': attributeOptions?.map((e) => e.toJson()).toList(),
      };
}
