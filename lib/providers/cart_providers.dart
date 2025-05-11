import 'dart:convert';

import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  static const _cartKey = 'user_cart';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  CartNotifier() : super([]) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final jsonString = await _secureStorage.read(key: _cartKey);
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      state = decoded.map((e) => CartItem.fromJson(e)).toList();
    }
  }

  Future<void> _saveCart() async {
    final jsonString = jsonEncode(state.map((e) => e.toJson()).toList());
    await _secureStorage.write(key: _cartKey, value: jsonString);
  }

  @override
  set state(List<CartItem> value) {
    super.state = value;
    _saveCart();
  }

  CartItem addCartItem(CartItem newItem) {
    final existingItemIndex =
        state.indexWhere((item) => item.sku?.id == newItem.sku?.id);

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

  void removeCartItems(List<String> cartItemIds) {
    state = state.where((item) => !cartItemIds.contains(item.id)).toList();
  }

  void toggleSelectCartItem(String skuId) {
    final cartItemIndex = state.indexWhere((item) => item.sku?.id == skuId);

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
