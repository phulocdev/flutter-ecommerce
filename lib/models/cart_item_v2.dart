import 'package:flutter_ecommerce/models/sku_item.dart';

class CartItemV2 {
  final SkuItem sku;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartItemV2({
    required this.sku,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemV2.fromJson(Map<String, dynamic> json) => CartItemV2(
        sku: SkuItem.fromJson(json['sku']),
        quantity: json['quantity'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'sku': sku.toJson(),
        'quantity': quantity,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
