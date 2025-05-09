import 'package:flutter_ecommerce/models/product.dart';

class CartItem {
  final String id;
  final int quantity;
  final double price;
  final bool isChecked;
  final Product product;

  CartItem({
    required this.id,
    required this.quantity,
    required this.price,
    this.isChecked = false,
    required this.product,
  });

  CartItem copyWith({
    String? id,
    int? quantity,
    double? price,
    bool? isChecked,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      isChecked: isChecked ?? this.isChecked,
      product: product ?? this.product,
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
      );
}
