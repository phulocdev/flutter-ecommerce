import 'package:flutter_ecommerce/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isChecked;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isChecked = true, 
  });

  double get totalPrice {
    return product.price * quantity;
  }
}