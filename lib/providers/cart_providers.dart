import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  CartItem addCartItem(CartItem newItem) {
    final existingItemIndex =
        state.indexWhere((item) => item.product.id == newItem.product.id);

    if (existingItemIndex > -1) {
      final existingItem = state[existingItemIndex];

      final updatedItem = existingItem.copyWith(
        quantity: newItem.quantity,
        price: newItem.price,
      );

      final newState = List<CartItem>.from(state);
      newState[existingItemIndex] = updatedItem;
      state = newState;
      return updatedItem;
    } else {
      state = [...state, newItem];
      return newItem;
    }
  }

  void updateCartItem(String cartItemId, int quantity) {
    final existingItemIndex = state.indexWhere((item) => item.id == cartItemId);
    if (existingItemIndex > -1) {
      final existingItem = state[existingItemIndex];

      final updatedItem = existingItem.copyWith(
        quantity: quantity,
      );
      final newState = List<CartItem>.from(state);
      newState[existingItemIndex] = updatedItem;
      state = newState;
    }
  }

  void removeCartItem(String cartItemId) {
    state = state.where((item) => item.id != cartItemId).toList();
  }

  void toggleSelectCartItem(String productId) {
    final cartItemIndex =
        state.indexWhere((item) => item.product.id == productId);

    if (cartItemIndex < 0) {
      return;
    }

    final targetCartItem = state[cartItemIndex];
    final updatedItem = targetCartItem.copyWith(
      isChecked: !targetCartItem.isChecked,
    );

    final newState = List<CartItem>.from(state);
    newState[cartItemIndex] = updatedItem;
    state = newState;
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
