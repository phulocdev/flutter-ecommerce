import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/category_api_service.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/models/dto/product_query_dto.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:flutter_ecommerce/widgets/products_each_category_section.dart';
import 'package:flutter_ecommerce/widgets/products_grid-view.dart';
import 'package:flutter_ecommerce/widgets/shimmer_loading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late List<Product> _featuredProducts = [];
  late List<Product> _newProducts = [];
  late List<Product> _bestSellerProducts = [];
  late List<Product> _promotionProducts = [];
  late List<Product> _searchResults = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isGridView = false;
  Category? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isSearchLoading = false;
  bool _showSearchResults = false;
  final ScrollController _scrollController = ScrollController();
  final productApiService = ProductApiService(ApiClient());
  final categoryApiService = CategoryApiService(ApiClient());
  Timer? _debounce;
  final GlobalKey _appBarKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _fetchProductAndCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchProductAndCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final featureProductsQuery = ProductQuery(
        pagination: PaginationQuery(page: 1, limit: 15),
        sort: 'views.desc',
      );

      final newProductsQuery = ProductQuery(
        pagination: PaginationQuery(page: 1, limit: 15),
        sort: 'createdAt.desc',
      );

      final bestSellerProductsQuery = ProductQuery(
        pagination: PaginationQuery(page: 1, limit: 15),
        sort: 'soldQuantity.desc',
      );

      final promotionProductsQuery = ProductQuery(
        pagination: PaginationQuery(page: 1, limit: 15),
        hasDiscount: 1,
      );

      final featureProducts =
          await productApiService.getProducts(query: featureProductsQuery);
      final newProducts =
          await productApiService.getProducts(query: newProductsQuery);
      final bestSellerProducts =
          await productApiService.getProducts(query: bestSellerProductsQuery);
      final promotionProducts =
          await productApiService.getProducts(query: promotionProductsQuery);

      setState(() {
        _featuredProducts = featureProducts;
        _newProducts = newProducts;
        _bestSellerProducts = bestSellerProducts;
        _promotionProducts = promotionProducts;
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

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearchLoading = true;
      _showSearchResults = true;
    });

    try {
      final searchQuery = ProductQuery(
        pagination: PaginationQuery(page: 1, limit: 10),
        name: query,
      );

      final results = await productApiService.getProducts(query: searchQuery);

      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSearchLoading = false;
        _searchResults = [];
      });
      print('Error searching products: $e');
    }
  }

  void _handleSearchInputChange(String value) {
    setState(() {
      _showSearchResults = value.isNotEmpty;
    });

    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 800), () {
      _searchProducts(value);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _showSearchResults = false;
        _searchResults = [];
      }
    });
  }

  void _selectSearchResult(Product product) {
    // Navigate to product detail or handle selection
    // For now, just close the search results
    setState(() {
      _showSearchResults = false;
      _isSearching = false;
      _searchController.clear();
    });

    navigateTo(context, '${AppRoute.productCatalog.path}/${product.id}');

    // You would typically navigate to the product detail page here
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    key: _appBarKey,
                    floating: true,
                    pinned: true,
                    snap: false,
                    elevation: 0,
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    title: _isSearching
                        ? CompositedTransformTarget(
                            link: _layerLink,
                            child: TextField(
                              controller: _searchController,
                              onChanged: _handleSearchInputChange,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sản phẩm...',
                                hintStyle: TextStyle(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.6)),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              // Image.asset(
                              //   'assets/images/logo.png',
                              //   height: 32,
                              // ),
                              const SizedBox(width: 8),
                              Text(
                                'Flutter Ecommerce',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: colorScheme.primary,
                        ),
                        onPressed: _toggleSearch,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          // Navigate to notifications
                        },
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(4.0),
                      child: Container(
                        height: 1.0,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
                ];
              },
              body: _isLoading
                  ? ShimmerLoading(isGridView: _isGridView)
                  : _hasError
                      ? _buildErrorView()
                      : _buildProductContent(),
            ),

            // Search results popover
            if (_showSearchResults && _isSearching)
              Positioned(
                top: kToolbarHeight + MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(
                      0, 56), // Adjust based on your app bar height
                  child: Material(
                    elevation: 8,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      color: colorScheme.surface,
                      child: _isSearchLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _searchResults.isEmpty
                              ? ListTile(
                                  title: Text(
                                    'Không tìm thấy sản phẩm',
                                    style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final product = _searchResults[index];
                                    return ListTile(
                                      leading: product.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                product.imageUrl!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons
                                                      .image_not_supported),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image),
                                            ),
                                      title: Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${product.formattedPrice} đ',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () => _selectSearchResult(product),
                                    );
                                  },
                                ),
                    ),
                  ),
                ),
              ),
          ],
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
          if (_featuredProducts.isNotEmpty &&
              _bestSellerProducts.isNotEmpty &&
              _newProducts.isNotEmpty)
            Expanded(
              child: _featuredProducts.isEmpty ||
                      _bestSellerProducts.isEmpty ||
                      _newProducts.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                      ? ProductsGridView(products: _featuredProducts)
                      : _buildCategorySections(),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySections() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductsEachCategorySection(
            title: 'Sản phẩm nổi bật',
            products: _featuredProducts,
            showSeeAll: true,
          ),
          ProductsEachCategorySection(
            title: 'Sản phẩm mới',
            products: _newProducts,
            showSeeAll: true,
          ),
          ProductsEachCategorySection(
            title: 'Bán chạy nhất',
            products: _bestSellerProducts,
            showSeeAll: true,
          ),
          ProductsEachCategorySection(
            title: 'Sản phẩm khuyến mãi',
            products: _promotionProducts,
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
