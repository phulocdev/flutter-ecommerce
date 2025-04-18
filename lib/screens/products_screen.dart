import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/data/dummy_products.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/widgets/cart_icon_button.dart';
import 'package:flutter_ecommerce/widgets/products_each_category_section.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final cartItemCount = ref.watch(cartTotalQuantityProvider);

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
        actions: [
          CartAppBarIcon(),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                screenHorizontalPadding,
                20.0,
                screenHorizontalPadding,
                sectionTitleBottomPadding,
              ),
              child: Text(
                '📌 Danh mục sản phẩm',
                style: textTheme.headlineSmall?.copyWith(
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
