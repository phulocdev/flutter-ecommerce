import 'package:flutter_ecommerce/models/product.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  void addNewCartItem(Product product) {
    state = [...state, product];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});
