import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/product_card.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasMoreData;

  const ProductGrid({
    Key? key,
    required this.products,
    required this.scrollController,
    required this.isLoading,
    required this.hasMoreData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine grid cross axis count based on screen size
    int crossAxisCount = 2; // Default for mobile

    if (ResponsiveBuilder.isTablet(context)) {
      crossAxisCount = 3;
    } else if (ResponsiveBuilder.isDesktop(context)) {
      crossAxisCount = 4;
    }

    return products.isEmpty
        ? const Center(child: Text('Danh sách sản phẩm trống'))
        : GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < products.length) {
                return ProductCard(product: products[index]);
              } else {
                // Loading indicator at the end
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          );
  }
}
