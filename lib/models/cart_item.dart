import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/models/sku.dart';

class CartItem {
  final String id;
  final int quantity;
  final double price;
  final bool isChecked;
  final Product product;
  final Sku? sku;

  CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    this.isChecked = false,
    required this.product,
    required this.sku,
  });

  CartItem copyWith({
    String? id,
    int? quantity,
    double? price,
    bool? isChecked,
    Product? product,
    Sku? sku,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
      product: product ?? this.product,
      sku: sku ?? this.sku,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quantity': quantity,
        'price': price,
        'isChecked': isChecked,
        'product': product.toJson(),
        'sku': sku?.toJson(), // Handle nullable sku
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      return CartItem(
        id: json['id'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] is int)
            ? (json['price'] as int).toDouble()
            : json['price'] as double,
        isChecked: json['isChecked'] as bool? ?? false,
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        sku: json['sku'] != null
            ? Sku.fromJson(json['sku'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing CartItem: $e');
      print('Json data: $json');
      // Try to identify which part is causing the issue
      if (json['product'] != null) {
        try {
          print('Testing product parsing...');
          Product.fromJson(json['product'] as Map<String, dynamic>);
          print('Product parsing succeeded');
        } catch (productError) {
          print('Error in product parsing: $productError');
        }
      }
      if (json['sku'] != null) {
        try {
          print('Testing sku parsing...');
          Sku.fromJson(json['sku'] as Map<String, dynamic>);
          print('Sku parsing succeeded');
        } catch (skuError) {
          print('Error in sku parsing: $skuError');
        }
      }
      rethrow;
    }
  }
}
