import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/widgets/cart_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    void clearCart() {
      ref.read(cartProvider.notifier).clearCart();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa tất cả sản phẩm trong giỏ hàng'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Giỏ hàng',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.white,
              ),
              tooltip: 'Xóa hết giỏ hàng',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: const Text(
                        'Bạn có chắc muốn xóa toàn bộ sản phẩm trong giỏ hàng?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        onPressed: clearCart,
                        child: Text('Xóa', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text(
                      '🛒 Giỏ hàng của bạn đang trống',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, index) {
                      return CartListItemWidget(cartItem: cartItems[index]);
                    },
                  ),
          ),
          if (cartItems.isNotEmpty) _buildSummarySection(context, cartItems),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, List<CartItem> cart) {
    final totalAmount = cart.where((item) => item.isChecked).fold<double>(
          0.0,
          (previousValue, item) => previousValue + (item.price * item.quantity),
        );
    final priceFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final formattedTotalAmount = priceFormatter.format(totalAmount);

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 6,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng cộng (tạm tính):',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: totalAmount <= 0
                  ? null
                  : () {
                      context.go(AppRoute.checkout.path);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Mua hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
