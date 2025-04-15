import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';

class ProductsListHorizontal extends StatelessWidget {
  const ProductsListHorizontal({super.key, required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
              width: 160,
              child: ProductCard(product: products[index]),
            ),
          );
        },
      ),
    );
  }
}