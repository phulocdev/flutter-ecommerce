import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/category_api_service.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/dto/date_range_query.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/models/dto/product_query_dto.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/category_tabs.dart';
import 'package:flutter_ecommerce/widgets/home_app_bar.dart';
import 'package:flutter_ecommerce/widgets/products_each_category_section.dart';
import 'package:flutter_ecommerce/widgets/products_grid-view.dart';
import 'package:flutter_ecommerce/widgets/shimmer_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late List<Product> _productList = [];
  late List<Category> _categoryList = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isGridView = false;
  Category? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();
  final productApiService = ProductApiService(ApiClient());
  final categoryApiService = CategoryApiService(ApiClient());

  @override
  void initState() {
    super.initState();
    _fetchProductAndCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductAndCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final query = ProductQuery(
        pagination: PaginationQuery(page: 1, limit: 20),
        dateRange: DateRangeQuery(
          from: DateTime(2024, 1, 1),
          to: DateTime(2025, 10, 30),
        ),
      );

      final productList = await productApiService.getProducts(query: query);
      final categoryList = await categoryApiService.getCategories();

      setState(() {
        _productList = productList;
        _categoryList = categoryList;
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
        .where((product) => product.category!.id == _selectedCategory!.id)
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              HomeAppBar(
                isSearching: _isSearching,
                searchController: _searchController,
                onSearchChanged: (value) => setState(() {}),
                onToggleSearch: _toggleSearch,
                colorScheme: colorScheme,
              ),
            ];
          },
          body: _isLoading
              ? ShimmerLoading(isGridView: _isGridView)
              : _hasError
                  ? _buildErrorView()
                  : _buildProductContent(),
        ),
      ),
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

  Widget _buildErrorView() {
    return RefreshIndicator(
      onRefresh: _fetchProductAndCategories,
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
              onPressed: _fetchProductAndCategories,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    return RefreshIndicator(
      onRefresh: _fetchProductAndCategories,
      child: Column(
        children: [
          if (_productList.isNotEmpty)
            CategoryTabs(
              categories: _categoryList,
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
                    : _buildCategorySections(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySections() {
    // Create different product sections for better organization
    final featuredProducts = _searchedProducts.take(5).toList();
    final newProducts = _searchedProducts.skip(5).take(5).toList();
    final bestSellers = _searchedProducts.skip(10).take(5).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductsEachCategorySection(
            title: 'Featured Products',
            products: featuredProducts,
            showSeeAll: true,
          ),
          ProductsEachCategorySection(
            title: 'New Arrivals',
            products: newProducts,
            showSeeAll: true,
          ),
          ProductsEachCategorySection(
            title: 'Best Sellers',
            products: bestSellers,
            showSeeAll: true,
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'Danh sách sản phẩm trống'
                : 'Danh sách sản phẩm trống',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Text('Xóa'),
            ),
        ],
      ),
    );
  }
}
