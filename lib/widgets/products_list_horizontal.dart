import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:go_router/go_router.dart';

class ProductsListHorizontal extends StatelessWidget {
  final List<Product> products;

  const ProductsListHorizontal({
    super.key,
    required this.products,
  });

  void _navigateToProductDetail(BuildContext context, Product product) {
    context.push(
      '/product/${product.id}',
      extra: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 150.0;
    const double listHeight = 240.0;
    const double horizontalPadding = 12.0;
    const double itemSpacing = 10.0;

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: 3),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: cardWidth,
            child: ProductCard(
              product: product,
              onTap: () => _navigateToProductDetail(context, product),
            ),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(width: itemSpacing),
      ),
    );
  }
}
