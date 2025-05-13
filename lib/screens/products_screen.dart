import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/category_tabs.dart';
import 'package:flutter_ecommerce/widgets/products_each_category_section.dart';
import 'package:flutter_ecommerce/widgets/products_grid-view.dart';
import 'package:flutter_ecommerce/widgets/shimmer_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  late List<Product> _productList = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isGridView = false;
  Category? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchProductList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductList() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final productApiService = ProductApiService(ApiClient());
      final productList = await productApiService.getProducts();
      setState(() {
        _productList = productList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load products. Please try again.';
      });
      print('Error fetching product list: $e');
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == null) {
      return _productList;
    }
    return _productList
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  List<Product> get _searchedProducts {
    if (_searchController.text.isEmpty) {
      return _filteredProducts;
    }
    return _filteredProducts
        .where((product) => product.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(theme, colorScheme),
      body: _isLoading
          ? ShimmerLoading(isGridView: _isGridView)
          : _hasError
              ? _buildErrorView()
              : _buildProductContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isGridView = !_isGridView;
          });
        },
        backgroundColor: colorScheme.primary,
        child: Icon(
          _isGridView ? Icons.view_list : Icons.grid_view,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.white,
      backgroundColor: theme.appBarTheme.backgroundColor ?? colorScheme.primary,
      elevation: theme.appBarTheme.elevation ?? 0.0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.onPrimary),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle:
                    TextStyle(color: colorScheme.onPrimary.withOpacity(0.7)),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
              autofocus: true,
            )
          : Text(
              'Flutter E-Commerce',
              style: theme.appBarTheme.titleTextStyle ??
                  TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
            ),
      centerTitle: false,
    );
  }

  Widget _buildErrorView() {
    return RefreshIndicator(
      onRefresh: _fetchProductList,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProductList,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    return RefreshIndicator(
      onRefresh: _fetchProductList,
      child: Column(
        children: [
          if (_productList.isNotEmpty)
            CategoryTabs(
              categories: [],
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          Expanded(
            child: _searchedProducts.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? ProductsGridView(products: _searchedProducts)
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductsEachCategorySection(
                              title: 'Sản phẩm nổi bật',
                              // p.discountPercentage > 0
                              products: _searchedProducts
                                  .where((p) => 1 > 0)
                                  .toList(),
                              showSeeAll: true,
                            ),
                            ProductsEachCategorySection(
                              title: 'Sản phẩm mới',
                              products: _searchedProducts,
                              showSeeAll: true,
                            ),
                            ProductsEachCategorySection(
                              title: 'Bán chạy nhất',
                              products: _searchedProducts,
                              showSeeAll: true,
                            ),
                            const SizedBox(height: 80), // Space for FAB
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_products.png',
            width: 150,
            height: 150,
            // If you don't have this asset, replace with:
            // Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No products match your search'
                : 'No products found in this category',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Text('Clear Search'),
            ),
        ],
      ),
    );
  }
}
