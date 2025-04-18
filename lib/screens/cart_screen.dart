import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ecommerce/providers/cart_provider.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/widgets/cart_list_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.cartItemsList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Xóa hết giỏ hàng',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: const Text('Bạn có chắc muốn xóa toàn bộ sản phẩm trong giỏ hàng?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                           Provider.of<CartProvider>(context, listen: false).clearCart();
                           Navigator.of(ctx).pop();
                        },
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
                      '🛒 Giỏ hàng của bạn đang trống!',
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
          if (cartItems.isNotEmpty)
            _buildSummarySection(context, cart),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartProvider cart) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 6,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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
                  cart.formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: cart.totalAmount <= 0 ? null : () {
                print('Tiến hành thanh toán với tổng tiền: ${cart.formattedTotalAmount}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng Thanh toán đang phát triển!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Mua hàng'),
            ),
          ],
        ),
      ),
    );
  }
}