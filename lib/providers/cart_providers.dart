import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:collection';

class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

  void addItem(Product product) {
    final Map<String, CartItem> newState = Map<String, CartItem>.from(state);

    if (newState.containsKey(product.id)) {
      // Product exists, increase quantity
      final existingItem = newState[product.id]!;
      newState[product.id] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Product doesn't exist, add as a new CartItem
      newState[product.id] = CartItem.fromProduct(product, quantity: 1);
    }

    state = newState;
  }

  void removeSingleItem(String productId) {
    final Map<String, CartItem> newState = Map<String, CartItem>.from(state);

    if (!newState.containsKey(productId)) {
      return;
    }

    final existingItem = newState[productId]!;

    if (existingItem.quantity > 1) {
      newState[productId] = existingItem.copyWith(
        quantity: existingItem.quantity - 1,
      );
    } else {
      newState.remove(productId);
    }

    state = newState;
  }

  void removeItem(String productId) {
    final Map<String, CartItem> newState = Map<String, CartItem>.from(state);

    if (newState.containsKey(productId)) {
      newState.remove(productId);
      state = newState;
    }
  }

  void clearCart() {
    state = {};
  }

  void setItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final Map<String, CartItem> newState = Map<String, CartItem>.from(state);
    if (newState.containsKey(productId)) {
      final existingItem = newState[productId]!;
      newState[productId] = existingItem.copyWith(quantity: quantity);
      state = newState;
    }
  }
}

// 1. The StateNotifierProvider for the CartNotifier itself
// This is what you'll use to access the notifier's methods (e.g., addItem)
final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartItem>>((ref) {
  return CartNotifier();
});

// 2. Provider for just the cart items (read-only map)
// Useful for widgets that only need to display the cart contents
final cartItemsProvider =
    Provider<UnmodifiableMapView<String, CartItem>>((ref) {
  final cartMap = ref.watch(cartNotifierProvider);
  return UnmodifiableMapView(cartMap);
});

// 3. Provider for the total number of UNIQUE items in the cart
// (e.g., 2 shirts, 1 pair of pants -> count is 2)
final cartItemCountProvider = Provider<int>((ref) {
  final cartMap = ref.watch(cartNotifierProvider);
  return cartMap.length;
});

// 4. Provider for the total QUANTITY of all items in the cart
// (e.g., 2 shirts, 1 pair of pants -> total quantity is 3)
final cartTotalQuantityProvider = Provider<int>((ref) {
  final cartMap = ref.watch(cartNotifierProvider);
  if (cartMap.isEmpty) {
    return 0;
  }
  return cartMap.values.fold(0, (sum, item) => sum + item.quantity);
});

// 5. Provider for the total monetary amount of the cart
final cartTotalAmountProvider = Provider<double>((ref) {
  final cartMap = ref.watch(cartNotifierProvider);
  if (cartMap.isEmpty) {
    return 0.0;
  }
  return cartMap.values
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
});

// 6. Provider to check if the cart is empty (convenience)
final isCartEmptyProvider = Provider<bool>((ref) {
  final cartMap = ref.watch(cartNotifierProvider);
  return cartMap.isEmpty;
});
