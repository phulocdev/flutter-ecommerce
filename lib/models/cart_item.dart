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
        'product': product.toJson(), // đảm bảo Product cũng có toJson
        'isChecked': isChecked,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        quantity: json['quantity'],
        price: json['price'],
        product: Product.fromJson(json['product']),
        isChecked: json['isChecked'] ?? false,
        sku: null,
      );
}
