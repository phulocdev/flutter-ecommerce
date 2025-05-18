import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/apis/category_api_service.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/dto/create_product_dto.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';
import 'package:flutter_ecommerce/models/dto/product_query_dto.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/product_form.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:intl/intl.dart';

// For product_management_screen.dart
final List<Map<String, dynamic>> _columnDefinitions = [
  {'field': 'code', 'text': 'Mã sản phẩm', 'flex': 2},
  {'field': 'name', 'text': 'Sản phẩm', 'flex': 3},
  {'field': 'description', 'text': 'Mô tả', 'flex': 3},
  {'field': 'basePrice', 'text': 'Giá', 'flex': 2},
  {'field': 'promotion', 'text': 'Khuyến mãi', 'flex': 2},
  {'field': 'status', 'text': 'Trạng thái', 'flex': 1},
  {'field': 'createdAt', 'text': 'Ngày tạo', 'flex': 1},
  {'field': 'updatedAt', 'text': 'Ngày cập nhật', 'flex': 2},
  {'field': 'actions', 'text': 'Hành động', 'flex': 2},
];

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final productApiService = ProductApiService(ApiClient());
  final categoriesApiService = CategoryApiService(ApiClient());
  final ScrollController _scrollController = ScrollController();
  late List<Product> _productList = [];
  late List<Category> _categoryList = [];
  Timer? _debounce;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  String _searchQuery = '';
  String _productCode = '';
  String? _selectedCategoryId;
  String? statusFilter;
  bool? _hasPromotion;
  int _currentPage = 1;
  final int _pageSize = 10;
  String _sortOption = 'createdAt.desc';
  String _sortField = 'createdAt';
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreProducts();
    }
  }

  void _updateSortOption(String field) {
    setState(() {
      if (_sortField == field) {
        // Toggle direction if same field
        _sortDirection = _sortDirection == 'asc' ? 'desc' : 'asc';
      } else {
        // New field, default to ascending
        _sortField = field;
        _sortDirection = 'asc';
      }
      _sortOption = '$_sortField.$_sortDirection';
    });
    _fetchData(resetCurrentPage: true);
  }

  Future<void> _fetchData({bool? resetCurrentPage}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = ProductQuery(
        pagination: PaginationQuery(
          page: resetCurrentPage != null ? 1 : _currentPage,
          limit: _pageSize,
        ),
        categoryIds:
            _selectedCategoryId != null ? [_selectedCategoryId!] : null,
        sort: _sortOption,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        code: _productCode.isNotEmpty ? _productCode : null,
        // hasPromotion: _hasPromotion,
      );

      final productList = await productApiService.getProducts(query: query);
      final categoryList = await categoriesApiService.getCategories();

      setState(() {
        _productList = productList;
        _categoryList = categoryList;
        _isLoading = false;
        _hasMoreData = productList.length >= _pageSize;
        if (resetCurrentPage == true) {
          _currentPage = 1;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Đã có lỗi xảy ra: $e');
      _showErrorSnackBar('Đã có lỗi xảy ra khi tải dữ liệu');
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = ProductQuery(
        pagination: PaginationQuery(page: _currentPage + 1, limit: _pageSize),
        categoryIds:
            _selectedCategoryId != null ? [_selectedCategoryId!] : null,
        sort: _sortOption,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        code: _productCode.isNotEmpty ? _productCode : null,
        // hasPromotion: _hasPromotion,
      );

      final newProducts = await productApiService.getProducts(query: query);

      setState(() {
        _productList.addAll(newProducts);
        _currentPage++;
        _hasMoreData = newProducts.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Lỗi khi tải thêm sản phẩm');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addProduct(CreateProductDto product) async {
    try {
      await productApiService.create(product);
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Thêm sản phẩm thành công');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi thêm sản phẩm: $e');
    }
  }

  void _deleteProduct(String productId) async {
    try {
      // In a real app, you would call the API to delete the product
      // await productApiService.deleteProduct(productId);

      // Refresh the product list
      _fetchData(resetCurrentPage: true);
      _showSuccessSnackBar('Xóa sản phẩm thành công');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi xóa sản phẩm: $e');
    }
  }

  void _navigateToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Thêm sản phẩm mới'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProductForm(
                onSave: _addProduct,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addPromotion(Product product) {
    final discountController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm khuyến mãi cho sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sản phẩm: ${product.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Giá gốc: ${product.formattedPrice}'),
              const SizedBox(height: 16),

              // Discount percentage field
              TextField(
                controller: discountController,
                decoration: const InputDecoration(
                  labelText: 'Phần trăm giảm giá (%)',
                  hintText: 'Nhập phần trăm giảm giá (tối đa 50%)',
                  border: OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),

              // Start date field
              TextField(
                controller: startDateController,
                decoration: InputDecoration(
                  labelText: 'Ngày bắt đầu',
                  hintText: 'Chọn ngày bắt đầu',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        startDate = date;
                        startDateController.text =
                            DateFormat('dd/MM/yyyy').format(date);
                      }
                    },
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // End date field
              TextField(
                controller: endDateController,
                decoration: InputDecoration(
                  labelText: 'Ngày kết thúc',
                  hintText: 'Chọn ngày kết thúc',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ??
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        endDate = date;
                        endDateController.text =
                            DateFormat('dd/MM/yyyy').format(date);
                      }
                    },
                  ),
                ),
                readOnly: true,
              ),

              const SizedBox(height: 16),
              // Preview discounted price
              if (discountController.text.isNotEmpty)
                Builder(
                  builder: (context) {
                    final discountPercent =
                        int.tryParse(discountController.text) ?? 0;
                    if (discountPercent > 0) {
                      final discountedPrice =
                          product.basePrice * (1 - discountPercent / 100);
                      final formatter = NumberFormat.currency(
                          locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá sau khuyến mãi: ${formatter.format(discountedPrice)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Tiết kiệm: ${formatter.format(product.basePrice - discountedPrice)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              final discountText = discountController.text.trim();
              if (discountText.isEmpty) {
                _showErrorSnackBar('Vui lòng nhập phần trăm giảm giá');
                return;
              }

              final discount = int.tryParse(discountText);
              if (discount == null || discount <= 0) {
                _showErrorSnackBar('Phần trăm giảm giá phải là số dương');
                return;
              }

              if (discount > 50) {
                _showErrorSnackBar('Phần trăm giảm giá tối đa là 50%');
                return;
              }

              if (startDate == null) {
                _showErrorSnackBar('Vui lòng chọn ngày bắt đầu');
                return;
              }

              if (endDate == null) {
                _showErrorSnackBar('Vui lòng chọn ngày kết thúc');
                return;
              }

              // Close dialog
              Navigator.pop(context);

              // Show loading
              _showLoadingDialog('Đang thêm khuyến mãi...');

              // Call API to add promotion
              Future.delayed(const Duration(seconds: 2), () {
                // In a real app, you would call the API to add promotion
                // productApiService.addPromotion(product.id, discount, startDate, endDate);

                // Close loading dialog
                Navigator.pop(context);

                // Show success message
                _showSuccessSnackBar('Thêm khuyến mãi thành công');

                // Refresh product list
                _fetchData(resetCurrentPage: true);
              });
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _handleSearchInputChange(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _searchQuery = value;
        _fetchData(resetCurrentPage: true);
      });
    });
  }

  void _handleProductCodeInputChange(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _productCode = value;
        _fetchData(resetCurrentPage: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveBuilder.isDesktop(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý sản phẩm',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý kho sản phẩm của bạn',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddProduct,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text('Thêm sản phẩm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Search and filter section
                // Replace the filter section in your product_management_screen.dart file with this code

// Search and filter section
                Card(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter section title
                        Row(
                          children: [
                            Icon(Icons.filter_list, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Bộ lọc tìm kiếm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                // Reset all filters
                                setState(() {
                                  _searchQuery = '';
                                  _productCode = '';
                                  _selectedCategoryId = null;
                                  _hasPromotion = null;
                                });
                                _fetchData(resetCurrentPage: true);
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Đặt lại'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // First row: Search and category filter
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search by name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 4),
                                    child: Text(
                                      'Tên sản phẩm',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm theo tên...',
                                      prefixIcon: Icon(Icons.search,
                                          color: colorScheme.primary),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: _handleSearchInputChange,
                                    onSubmitted: (_) =>
                                        _fetchData(resetCurrentPage: true),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Category dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 4),
                                    child: Text(
                                      'Danh mục',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Chọn danh mục',
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14),
                                        ),
                                        value: _selectedCategoryId,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: colorScheme.primary),
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14),
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: null,
                                            child: Text(
                                              'Tất cả danh mục',
                                              style: TextStyle(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          ..._categoryList.map(
                                            (category) =>
                                                DropdownMenuItem<String>(
                                              value: category.id,
                                              child: Text(category.name),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategoryId = value;
                                          });
                                          _fetchData(resetCurrentPage: true);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Second row: Product code filter and promotion filter
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product code search
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 4),
                                    child: Text(
                                      'Mã sản phẩm',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Tìm kiếm theo mã...',
                                      prefixIcon: Icon(Icons.qr_code,
                                          color: colorScheme.primary),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: _handleProductCodeInputChange,
                                    onSubmitted: (_) =>
                                        _fetchData(resetCurrentPage: true),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Promotion filter
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 4),
                                    child: Text(
                                      'Khuyến mãi',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<bool?>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Trạng thái khuyến mãi',
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14),
                                        ),
                                        value: _hasPromotion,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: colorScheme.primary),
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14),
                                        items: [
                                          DropdownMenuItem<bool?>(
                                            value: null,
                                            child: Text(
                                              'Tất cả sản phẩm',
                                              style: TextStyle(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          DropdownMenuItem<bool?>(
                                            value: true,
                                            child: Row(
                                              children: [
                                                Icon(Icons.local_offer,
                                                    size: 16,
                                                    color: Colors.red.shade400),
                                                const SizedBox(width: 8),
                                                const Text('Có khuyến mãi'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem<bool?>(
                                            value: false,
                                            child: Row(
                                              children: [
                                                Icon(Icons.money_off,
                                                    size: 16,
                                                    color:
                                                        Colors.grey.shade600),
                                                const SizedBox(width: 8),
                                                const Text('Không khuyến mãi'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _hasPromotion = value;
                                          });
                                          _fetchData(resetCurrentPage: true);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Status filter chips with improved styling
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'Trạng thái sản phẩm',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip(
                                      'Tất cả', true, Icons.all_inclusive),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                      'Đã đăng', false, Icons.inventory),
                                  const SizedBox(width: 8),
                                  _buildFilterChip(
                                      'Bản nháp', false, Icons.warning_amber),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('Đã ẩn', false,
                                      Icons.remove_shopping_cart),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Products table with sortable headers
                Expanded(
                  child: _productList.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            // Table header with sort buttons
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: _columnDefinitions.map((column) {
                                  if (column['field'] == 'actions') {
                                    return Container(
                                      width: 180, // Fixed width for actions
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: const Text(
                                        'Hành động',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return _buildSortableHeader(
                                      field: column['field'],
                                      text: column['text'],
                                      flex: column['flex'],
                                    );
                                  }
                                }).toList(),
                              ),
                            ),

                            // Table body
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                // ---------------- LIST PRODUCTS ----------
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: _productList.length,
                                  itemBuilder: (context, index) {
                                    final product = _productList[index];
                                    final hasPromotion =
                                        false; // Replace with actual promotion check
                                    final discountPercent =
                                        0; // Replace with actual discount percent

                                    return Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey.shade50,
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200),
                                        ),
                                      ),
                                      child: Row(
                                        children: // Product Management Table Cells
                                            [
                                          // Product code
                                          Expanded(
                                            flex: _columnDefinitions[0]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                product.code,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Product name with image
                                          Expanded(
                                            flex: _columnDefinitions[1]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      child: product.imageUrl
                                                              .isNotEmpty
                                                          ? Image.network(
                                                              product.imageUrl,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  const Icon(Icons
                                                                      .image_not_supported_outlined),
                                                            )
                                                          : const Icon(Icons
                                                              .image_outlined),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Flexible(
                                                    child: Text(
                                                      product.name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Description
                                          Expanded(
                                            flex: _columnDefinitions[2]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                product.description,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Price
                                          Expanded(
                                            flex: _columnDefinitions[3]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                product.formattedPrice,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Promotion
                                          Expanded(
                                            flex: _columnDefinitions[4]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: hasPromotion
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .red.shade50,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .red
                                                                    .shade200),
                                                          ),
                                                          child: Text(
                                                            'Giảm $discountPercent%',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .red.shade700,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          'Còn 7 ngày', // Replace with actual days remaining
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const Text(
                                                      'Không có',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          // Status
                                          Expanded(
                                            flex: _columnDefinitions[5]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          product.status)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  product.status,
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                        product.status),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Created date
                                          Expanded(
                                            flex: _columnDefinitions[6]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                DateFormat('dd/MM/yyyy')
                                                    .format(product.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Updated date
                                          Expanded(
                                            flex: _columnDefinitions[7]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                DateFormat('dd/MM/yyyy')
                                                    .format(product.updatedAt),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Actions
                                          Expanded(
                                            flex: _columnDefinitions[8]['flex'],
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Edit button
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    tooltip:
                                                        'Chỉnh sửa sản phẩm',
                                                    onPressed: () {
                                                      // Navigate to product form with product data
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Scaffold(
                                                            appBar: AppBar(
                                                              title: const Text(
                                                                  'Chỉnh sửa sản phẩm'),
                                                            ),
                                                            body:
                                                                SingleChildScrollView(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16.0),
                                                                child:
                                                                    ProductForm(
                                                                  product:
                                                                      _convertToCreateProductDto(
                                                                          product),
                                                                  onSave:
                                                                      (updatedProduct) {
                                                                    // Handle product update
                                                                    _fetchData(
                                                                        resetCurrentPage:
                                                                            true);
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),

                                                  // Add promotion button
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.local_offer,
                                                        color: Colors.orange),
                                                    tooltip: 'Thêm khuyến mãi',
                                                    onPressed: () =>
                                                        _addPromotion(product),
                                                  ),

                                                  // Delete button
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    tooltip: 'Xóa sản phẩm',
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                            context,
                                                            product.id),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Loading indicator for infinite loading
                            if (_isLoadingMore)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải dữ liệu...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to convert Product to CreateProductDto
  dynamic _convertToCreateProductDto(Product product) {
    return {
      'name': product.name,
      'description': product.description,
      'category': product.category?.id,
      'brand': product.brand?.id,
      'basePrice': product.basePrice,
      'minStockLevel': product.minStockLevel,
      'maxStockLevel': product.maxStockLevel,
      'imageUrl': product.imageUrl,
      // Add other fields as needed
    };
  }

  Widget _buildTableCell({
    required int flex,
    required Widget child,
  }) {
    // Calculate minimum width based on flex
    final double minWidth = 100.0 * flex;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildSortableHeader(
      {required String field, required String text, required int flex}) {
    final bool isActive = _sortField == field;
    final bool isAscending = _sortDirection == 'asc';

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _updateSortOption(field),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? Colors.blue.shade700 : Colors.black,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Show loading indicator
              _showLoadingDialog('Đang xóa sản phẩm...');

              // Simulate API call with Future.delayed
              Future.delayed(const Duration(seconds: 2), () {
                // Call the API service to delete the product
                try {
                  // This would be your actual API call
                  // productApiService.deleteProduct(productId);

                  // Close loading dialog
                  Navigator.pop(context);

                  // Delete the product
                  _deleteProduct(productId);
                } catch (e) {
                  // Close loading dialog
                  Navigator.pop(context);

                  // Show error message
                  _showErrorSnackBar('Lỗi khi xóa sản phẩm: $e');
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'archived':
        return Colors.blue;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Add this helper method to your class
  Widget _buildFilterChip(String label, bool selected, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (value) {
        // Handle filter selection
        print(value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.lightBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.grey.shade800,
        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
      ),
      elevation: selected ? 1 : 0,
      pressElevation: 2,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sản phẩm đầu tiên của bạn để bắt đầu',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('Thêm sản phẩm'),
          ),
        ],
      ),
    );
  }
}
