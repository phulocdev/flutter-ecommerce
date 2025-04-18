import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CartAppBarIcon extends ConsumerWidget {
  const CartAppBarIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuantity = ref.watch(cartTotalQuantityProvider);

    return Badge(
      label: Text(totalQuantity.toString()),
      isLabelVisible: totalQuantity > 0,
      child: IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () {},
      ),
    );
  }
}

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final totalAmount = ref.watch(cartTotalAmountProvider);
    final isCartEmpty = ref.watch(isCartEmptyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: isCartEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, index) {
                      final item = cartItems.values.elementAt(index);
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            ref
                                .read(cartNotifierProvider.notifier)
                                .removeSingleItem(item.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20)),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).clearCart();
                  },
                  child: const Text('Checkout / Clear Cart'),
                )
              ],
            ),
    );
  }
}
