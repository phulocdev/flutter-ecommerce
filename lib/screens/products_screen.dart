import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/products_each_category_section.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  late List<Product> _productList;

  @override
  void initState() {
    super.initState();
    _fetchProductList();
  }

  Future<void> _fetchProductList() async {
    try {
      final productApiService = ProductApiService(ApiClient());
      final productList = await productApiService.getProducts();

      print(productList);
      setState(() {
        _productList = productList;
      });
    } catch (e) {
      print('Error fetching product list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    const double screenHorizontalPadding = 12.0;
    const double sectionTitleBottomPadding = 12.0;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.white,
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.blue,
        elevation: theme.appBarTheme.elevation ?? 2.0,
        title: Text(
          'Products',
          style: theme.appBarTheme.titleTextStyle ??
              const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 24),
        ),
        centerTitle: true,
        // actions: [Icon(Icons.shopping_cart)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductsEachCategorySection(
              title: '🔥 Khuyến mãi đặc biệt',
              products: _productList,
            ),
            // ProductsEachCategorySection(
            //   title: '🆕 Sản phẩm mới',
            //   products: newProducts,
            // ),
            // ProductsEachCategorySection(
            //   title: '🏆 Bán chạy nhất',
            //   products: bestSellers,
            // ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(
            //     screenHorizontalPadding,
            //     20.0,
            //     screenHorizontalPadding,
            //     sectionTitleBottomPadding,
            //   ),
            //   child: Text(
            //     '📌 Danh mục sản phẩm',
            //     style: textTheme.headlineSmall?.copyWith(
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // ProductsEachCategorySection(
            //   title: '💾 Ổ cứng',
            //   products: storageProducts,
            // ),
            // ProductsEachCategorySection(
            //   title: '🖥️ Màn hình',
            //   products: monitorProducts,
            // ),
            // ProductsEachCategorySection(
            //   title: '💻 Laptop',
            //   products: laptopProducts,
            // ),
            // ProductsEachCategorySection(
            //   title: '🖱️ Chuột',
            //   products: mouseProducts,
            // ),
            // ProductsEachCategorySection(
            //   title: '⌨️ Bàn phím',
            //   products: keyboardProducts,
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
