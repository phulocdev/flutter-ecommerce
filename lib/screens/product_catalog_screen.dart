import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/dto/date_range_query.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/models/dto/product_query_dto.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/filter_sidebar.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/product_grid.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/product_list.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/catalog_banner.dart';
import 'package:flutter_ecommerce/widgets/product_catalog/sort_dropdown.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';

const MAX_PRICE_FILTER = 80000000.00;

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({Key? key}) : super(key: key);

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final ProductApiService _productService = ProductApiService(ApiClient());
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMoreData = true;
  String _sortOption = 'createdAt.desc';
  bool _isGridView = true;

  List<Product> _products = [];
  int _currentPage = 1;
  final int _pageSize = 10;

  // Filter states
  List<String> _selectedCategoryIds = [];
  RangeValues _priceRange = const RangeValues(0, MAX_PRICE_FILTER);
  double _minRating = 0;
  List<String> _selectedBrandIds = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Add scroll listener for infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMoreData) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool? resetCurrentPage = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final query = ProductQuery(
        pagination: PaginationQuery(
            page: resetCurrentPage != null ? 1 : _currentPage,
            limit: _pageSize),
        // dateRange: DateRangeQuery(
        //   from: DateTime(2024, 1, 1),
        //   to: DateTime(2025, 10, 30),
        // ),
        categoryIds: _selectedCategoryIds,
        brandIds: _selectedBrandIds,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        sort: _sortOption,
      );
      //   minRating: _minRating,

      final newProducts = await _productService.getProducts(query: query);

      setState(() {
        _products = newProducts;
        _currentPage = 1;
        _hasMoreData = newProducts.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Đã có lỗi xảy ra');
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final query = ProductQuery(
          pagination: PaginationQuery(page: _currentPage + 1, limit: _pageSize),
          // dateRange: DateRangeQuery(
          //   from: DateTime(2024, 1, 1),
          //   to: DateTime(2025, 10, 30),
          // ),
          categoryIds: _selectedCategoryIds,
          brandIds: _selectedBrandIds,
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
          sort: _sortOption);

      //    sortBy: _sortOption,
      // minRating: _minRating,

      final newProducts = await _productService.getProducts(query: query);

      setState(() {
        _products.addAll(newProducts);
        _currentPage++;
        _hasMoreData = newProducts.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi khi tải thêm sản phẩm');
    }
  }

  void _applyFilters({
    List<String>? categories,
    RangeValues? priceRange,
    double? minRating,
    List<String>? brands,
  }) {
    setState(() {
      if (categories != null) _selectedCategoryIds = categories;
      if (priceRange != null) _priceRange = priceRange;
      if (minRating != null) _minRating = minRating;
      if (brands != null) _selectedBrandIds = brands;
    });
    _loadProducts(resetCurrentPage: true);
  }

  void _applySorting(String sortOption) {
    setState(() {
      _sortOption = sortOption;
    });

    _loadProducts();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Ecommerce',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Xem ở dạng hàng' : 'Xem ở dạng lưới',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ResponsiveBuilder(
          // Mobile layout (stacked)
          mobile: _buildMobileLayout(),

          // Tablet and Desktop layout (side-by-side)
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Expandable filter section
        ExpansionTile(
          title: const Text('Bộ lọc sản phẩm',
              style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            FilterSidebar(
              selectedCategories: _selectedCategoryIds,
              priceRange: _priceRange,
              minRating: _minRating,
              selectedBrands: _selectedBrandIds,
              onApplyFilters: _applyFilters,
              maxPrice: MAX_PRICE_FILTER, // Set your max price here
            ),
          ],
        ),

        // Product section
        Expanded(
          child: _buildProductSection(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter sidebar (30% width)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: FilterSidebar(
            selectedCategories: _selectedCategoryIds,
            priceRange: _priceRange,
            minRating: _minRating,
            selectedBrands: _selectedBrandIds,
            onApplyFilters: _applyFilters,
            maxPrice: MAX_PRICE_FILTER, // Set your max price here
          ),
        ),

        // Product section (70% width)
        Expanded(
          child: _buildProductSection(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter sidebar (20% width)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: FilterSidebar(
            selectedCategories: _selectedCategoryIds,
            priceRange: _priceRange,
            minRating: _minRating,
            selectedBrands: _selectedBrandIds,
            onApplyFilters: _applyFilters,
            maxPrice: MAX_PRICE_FILTER, // Set your max price here
          ),
        ),

        // Product section (80% width)
        Expanded(
          child: _buildProductSection(),
        ),
      ],
    );
  }

  Widget _buildProductSection() {
    return Column(
      children: [
        // Banner
        const CatalogBanner(),

        // Sort dropdown and results count
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveBuilder(
            mobile: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  '${_products.length} sản phẩm được tìm thấy',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: SortDropdown(
                    currentSortOption: _sortOption,
                    onSortChanged: _applySorting,
                  ),
                ),
              ],
            ),
            tablet: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_products.length} sản phẩm được tìm thấy',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SortDropdown(
                  currentSortOption: _sortOption,
                  onSortChanged: _applySorting,
                ),
              ],
            ),
            desktop: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_products.length} sản phẩm được tìm thấy',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SortDropdown(
                  currentSortOption: _sortOption,
                  onSortChanged: _applySorting,
                ),
              ],
            ),
          ),
        ),

        // Product grid or list
        Expanded(
          child: _isGridView
              ? ProductGrid(
                  products: _products,
                  scrollController: _scrollController,
                  isLoading: _isLoading,
                  hasMoreData: _hasMoreData,
                )
              : ProductList(
                  products: _products,
                  scrollController: _scrollController,
                  isLoading: _isLoading,
                  hasMoreData: _hasMoreData,
                ),
        ),
      ],
    );
  }
}
