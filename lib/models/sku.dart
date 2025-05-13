import 'package:flutter_ecommerce/models/attribute.dart';
import 'package:intl/intl.dart';

class Sku {
  final String _id;
  final String sku;
  final String barcode;
  final double costPrice;
  final double sellingPrice;
  final int stockOnHand;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Attribute>? attributes;

  const Sku({
    required String id,
    required this.sku,
    required this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockOnHand,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.attributes,
  }) : _id = id;

  String get id => _id;

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(sellingPrice);
  }

  String get formattedCostPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(costPrice);
  }

  factory Sku.fromJson(Map<String, dynamic> json) => Sku(
        id: json['_id'],
        sku: json['sku'],
        barcode: json['barcode'],
        costPrice: (json['costPrice'] as num).toDouble(),
        sellingPrice: (json['sellingPrice'] as num).toDouble(),
        stockOnHand: json['stockOnHand'],
        imageUrl: json['imageUrl']?.toString() ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        attributes: json['attributes'] != null
            ? (json['attributes'] as List)
                .map((e) => Attribute.fromJson(e))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': _id,
        'sku': sku,
        'barcode': barcode,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'stockOnHand': stockOnHand,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'attributes': attributes?.map((e) => e.toJson()).toList(),
      };
}
