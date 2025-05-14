import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/product_list_item.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasMoreData;

  const ProductList({
    Key? key,
    required this.products,
    required this.scrollController,
    required this.isLoading,
    required this.hasMoreData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? const Center(child: Text('Danh sách sản phẩm trống'))
        : ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: products.length + (isLoading ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              if (index < products.length) {
                return ProductListItem(product: products[index]);
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
