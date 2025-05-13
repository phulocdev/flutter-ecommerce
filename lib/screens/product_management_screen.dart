import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/category_api_service.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/dto/create_product_dto.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/product_form.dart';
import 'package:flutter_ecommerce/widgets/product_management_table.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:go_router/go_router.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late List<Product> _productList = [];
  late List<Category> _categoryList = [];

  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProductsAndCategories();
  }

  Future<void> _loadProductsAndCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productApiService = ProductApiService(ApiClient());
      final productList = await productApiService.getProducts();
      final categoriesApiService = CategoryApiService(ApiClient());
      final categoryList = await categoriesApiService.getCategories();

      setState(() {
        _productList = productList;
        _categoryList = categoryList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching product list: $e');
    }

    // In a real app, you would fetch products from an API
    setState(() {
      _isLoading = false;
    });
  }

  void _addProduct(CreateProductDto product) async {
    final productApiService = ProductApiService(ApiClient());
    await productApiService.create(product);
    final productList = await productApiService.getProducts();

    setState(() {
      _productList = productList;
    });
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

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveBuilder.isDesktop(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
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

                  const SizedBox(height: 24),

                  // Search and filter section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Tìm kiếm sản phẩm...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              DropdownButton<String>(
                                hint: const Text('Danh mục'),
                                value: _selectedCategory,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Tất cả danh mục'),
                                  ),
                                  ..._categoryList.map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('Tất cả'),
                                  selected: true,
                                  onSelected: (selected) {},
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Còn hàng'),
                                  selected: false,
                                  onSelected: (selected) {},
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Sắp hết'),
                                  selected: false,
                                  onSelected: (selected) {},
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Hết hàng'),
                                  selected: false,
                                  onSelected: (selected) {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Products table or grid
                  Expanded(
                    child: _productList.isEmpty
                        ? _buildEmptyState()
                        : ProductManagementTable(products: _productList),
                  ),
                ],
              ),
            ),
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
