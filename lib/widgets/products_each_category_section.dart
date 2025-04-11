import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/products_list_horizontal.dart';

class ProductsEachCategorySection extends StatelessWidget {
  final String title;
  final List<Product> products;

  const ProductsEachCategorySection(
      {super.key, required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ProductsListHorizontal(products: products),
        ],
      ),
    );
  }
}
