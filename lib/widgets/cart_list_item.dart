// widgets/cart_list_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/providers/cart_provider.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen.dart';

class CartListItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartListItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: cartItem.isChecked,
              onChanged: (value) {
                cartProvider.toggleItemChecked(cartItem.product.id);
              },
              activeColor: Theme.of(context).colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ProductDetail(product: cartItem.product),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          cartItem.product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.product.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cartItem.product.formattedPrice,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildQuantityButton(
                                      context,
                                      Icons.remove,
                                      cartItem.quantity > 1
                                          ? () {
                                              cartProvider.updateQuantity(cartItem.product.id, cartItem.quantity - 1);
                                            }
                                          : null),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _buildQuantityButton(context, Icons.add, () {
                                    cartProvider.updateQuantity(cartItem.product.id, cartItem.quantity + 1);
                                  }),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 22),
                                tooltip: 'Xóa sản phẩm',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  cartProvider.removeItem(cartItem.product.id);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('${cartItem.product.name} đã bị xóa.'),
                                        duration: const Duration(seconds: 1)),
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(BuildContext context, IconData icon, VoidCallback? onPressed) {
     return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: onPressed != null ? Colors.grey[400]! : Colors.grey[200]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
              icon,
              size: 18,
              color: onPressed != null ? Colors.black54 : Colors.grey[400]
          ),
        ),
     );
  }
}