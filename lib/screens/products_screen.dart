import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/data/dummy_products.dart';
import 'package:flutter_ecommerce/widgets/products_each_category_section.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Trang chủ',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {

            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {

            },
          ),
          const SizedBox(width: 8),
        ],

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductsEachCategorySection(
              title: '🔥 Khuyến mãi đặc biệt',
              products: discountedProducts,
            ),
            ProductsEachCategorySection(
              title: '🆕 Sản phẩm mới',
              products: newProducts,
            ),
            ProductsEachCategorySection(
              title: '🏆 Bán chạy nhất',
              products: bestSellers,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              child: Text(
                '📌 Danh mục sản phẩm',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProductsEachCategorySection(
              title: '💾 Ổ cứng',
              products: storageProducts,
            ),
            ProductsEachCategorySection(
              title: '🖥️ Màn hình',
              products: monitorProducts,
            ),
            ProductsEachCategorySection(
              title: '💻 Laptop',
              products: laptopProducts,
            ),
            ProductsEachCategorySection(
              title: '🖱️ Chuột',
              products: mouseProducts,
            ),
            ProductsEachCategorySection(
              title: '⌨️ Bàn phím',
              products: keyboardProducts,
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}