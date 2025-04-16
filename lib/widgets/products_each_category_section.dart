import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/products_list_horizontal.dart';

class ProductsEachCategorySection extends StatelessWidget {
  final String title;
  final List<Product> products;

  const ProductsEachCategorySection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    const double sectionVerticalPadding = 32.0;
    const double horizontalPadding = 12.0;

    if (products.isEmpty) {}

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: sectionVerticalPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(),
            ),
          ),
          ProductsListHorizontal(products: products),
        ],
      ),
    );
  }
}
