import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/widgets/products_list_horizontal.dart';
import 'package:go_router/go_router.dart';

class ProductsEachCategorySection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool showSeeAll;

  const ProductsEachCategorySection({
    super.key,
    required this.title,
    required this.products,
    this.showSeeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    const double sectionVerticalPadding = 16.0;
    const double horizontalPadding = 16.0;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: sectionVerticalPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                if (showSeeAll && products.length > 5)
                  TextButton.icon(
                    onPressed: () {
                      context.push(AppRoute.productCatalog.path);
                    },
                    icon: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    label: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          ProductsListHorizontal(products: products),
        ],
      ),
    );
  }
}
