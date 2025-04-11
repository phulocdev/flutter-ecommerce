import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';

class ProductsListHorizontal extends StatelessWidget {
  const ProductsListHorizontal({super.key, required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    const double totalVerticalPadding = 20.0;
    const double availableHeight = 220.0 - totalVerticalPadding;
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPaddingAndSpacing = 44.0;
    final double desiredWidth = (screenWidth - horizontalPaddingAndSpacing) / 3;
    final double calculatedAspectRatio =
        availableHeight > 0 ? (desiredWidth / availableHeight) : 5;

    return SizedBox(
      height: 220,
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: calculatedAspectRatio,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),
    );
  }
}
