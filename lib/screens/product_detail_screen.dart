import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/providers/cart_provider.dart';
import 'package:flutter_ecommerce/screens/cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          product.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
          overflow: TextOverflow.ellipsis,
        ),

      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Mô tả sản phẩm:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  label: const Text('Thêm vào giỏ'),
                  onPressed: () {
                    final cart = Provider.of<CartProvider>(context, listen: false);
                    cart.addItem(product);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} đã được thêm vào giỏ!'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green[700],
                        action: SnackBarAction(
                          label: 'XEM GIỎ',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => const CartScreen(),
                                  ),
                                );
                          },
                        ),
                      ),
                    );
                    print('Thêm vào giỏ hàng: ${product.name}');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary, side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  child: const Text('Mua ngay'),
                  onPressed: () {
                     final cart = Provider.of<CartProvider>(context, listen: false);
                     cart.addItem(product);

                    print('Mua ngay: ${product.name}');
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng Mua ngay đang phát triển!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}