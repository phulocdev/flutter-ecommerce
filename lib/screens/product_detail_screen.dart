import 'dart:async';

import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/models/sku.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  Sku? _selectedSku;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final productApiService = ProductApiService(ApiClient());
      final product = await productApiService.getProductById(widget.productId);

      setState(() {
        _product = product;
        final sortedSkus = [...(product.skus ?? [])]
          ..sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        _selectedSku = sortedSkus.isNotEmpty ? sortedSkus.first : null;
      });
    } catch (e) {
      print('Error fetching product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    void addProductToCart({bool isBuyNow = false}) {
      if (_product == null) {
        return;
      }

      ref.read(cartProvider.notifier).addCartItem(
            CartItem(
              id: DateTime.now().toString(),
              quantity: _quantity,
              price: _selectedSku!.sellingPrice,
              product: _product!,
              isChecked: isBuyNow,
              sku: _selectedSku,
            ),
          );

      if (!isBuyNow) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm sản phẩm vào giỏ hàng'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green[700],
            action: SnackBarAction(
              label: 'Xem giỏ hàng',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to cart screen using GoRouter
                context.goNamed(AppRoute.cart.name);
              },
            ),
          ),
        );
      } else {
        context.go(AppRoute.cart.path);
      }
    }

    print(">>>>>>>> ${_product!.toJson()}");

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: Text(
          _product != null ? _product!.name : '',
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
                      _product!.imageUrl,
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
                            child: Icon(Icons.broken_image,
                                color: Colors.grey, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    _product!.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _selectedSku!.formattedPrice,
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
                    _product!.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 30.0),

                  // Variants
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân loại hàng:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _product!.skus!.map((sku) {
                          final isSelected = _selectedSku?.id == sku.id;
                          final variantsName = sku.attributes
                              ?.map((att) => att.value)
                              .join(' - ');

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSku = sku;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                variantsName ?? '',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Số lượng:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              splashRadius: 20,
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              splashRadius: 20,
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                    label: const Text(
                      'Thêm vào giỏ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: addProductToCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.flash_on_outlined, size: 22),
                    label: const Text(
                      'Mua ngay',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => addProductToCart(isBuyNow: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
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
