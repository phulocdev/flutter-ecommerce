import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:go_router/go_router.dart';

class ProductsGridView extends StatelessWidget {
  final List<Product> products;

  const ProductsGridView({
    super.key,
    required this.products,
  });

  void _navigateToProductDetail(BuildContext context, Product product) {
    // context.go(
    //   '${AppRoute.productCatalog.path}/${product.id}',
    // );
    navigateTo(context, '${AppRoute.productCatalog.path}/${product.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => _navigateToProductDetail(context, product),
          isHorizontal: false,
        );
      },
    );
  }
}
