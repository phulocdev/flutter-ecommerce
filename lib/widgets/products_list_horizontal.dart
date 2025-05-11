import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:go_router/go_router.dart';

class ProductsListHorizontal extends StatelessWidget {
  final List<Product> products;

  const ProductsListHorizontal({
    super.key,
    required this.products,
  });

  void _navigateToProductDetail(BuildContext context, Product product) {
    context.go(
      '${AppRoute.products.path}/${product.id}', // Chú ý dấu '/' ở giữa
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 160.0;
    const double listHeight = 260.0;
    const double horizontalPadding = 16.0;
    const double itemSpacing = 16.0;

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(
                right: index == products.length - 1 ? 0 : itemSpacing),
            child: ProductCard(
              product: product,
              onTap: () => _navigateToProductDetail(context, product),
            ),
          );
        },
      ),
    );
  }
}
