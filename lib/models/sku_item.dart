import 'package:flutter_ecommerce/models/attribute.dart';
import 'package:flutter_ecommerce/models/product_summary.dart';

class SkuItem {
  final String _id;
  final String sku;
  final ProductSummary product;
  final String barcode;
  final double costPrice;
  final int stockOnHand;
  final List<Attribute> attributes;
  final double sellingPrice;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SkuItem({
    required String id,
    required this.sku,
    required this.product,
    required this.barcode,
    required this.costPrice,
    required this.stockOnHand,
    required this.attributes,
    required this.sellingPrice,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : _id = id;

  String get id => _id;

  factory SkuItem.fromJson(Map<String, dynamic> json) => SkuItem(
        id: json['_id'],
        sku: json['sku'],
        product: ProductSummary.fromJson(json['product']),
        barcode: json['barcode'],
        costPrice: (json['costPrice'] as num).toDouble(),
        stockOnHand: json['stockOnHand'],
        attributes: (json['attributes'] as List)
            .map((e) => Attribute.fromJson(e))
            .toList(),
        sellingPrice: (json['sellingPrice'] as num).toDouble(),
        imageUrl: json['imageUrl'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'product': product.toJson(),
        'barcode': barcode,
        'costPrice': costPrice,
        'stockOnHand': stockOnHand,
        'attributes': attributes.map((e) => e.toJson()).toList(),
        'sellingPrice': sellingPrice,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
