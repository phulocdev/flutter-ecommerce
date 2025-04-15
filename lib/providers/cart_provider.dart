import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  List<CartItem> get cartItemsList => _items.values.toList();

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isChecked) {
        total += cartItem.totalPrice;
      }
    });
    return total;
  }

  String get formattedTotalAmount {
    final priceFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return priceFormatter.format(totalAmount);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
          isChecked: existingCartItem.isChecked,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: 1,
          isChecked: false,
        ),
      );
    }
    notifyListeners();
  }

  void toggleItemChecked(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.isChecked = !_items[productId]!.isChecked;
      notifyListeners();
    }
  }

  void toggleAllItemsChecked(bool isChecked) {
    _items.forEach((key, cartItem) {
      cartItem.isChecked = isChecked;
    });
    notifyListeners();
  }


  void updateQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity > 0) {
        _items.update(
            productId,
            (existing) => CartItem(
                product: existing.product,
                quantity: newQuantity,
                isChecked: existing.isChecked));
      } else {
        removeItem(productId);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}