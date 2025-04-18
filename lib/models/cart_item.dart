import 'package:flutter_ecommerce/models/product.dart';

class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      id: product.id,
      name: product.name,
      quantity: quantity,
      price: product.price,
      imageUrl: product.imageUrl,
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      price: price,
      imageUrl: imageUrl,
    );
  }
}
