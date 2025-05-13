import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/models/sku.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class ProductDetailAdminScreen extends StatefulWidget {
  final String productId;

  const ProductDetailAdminScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailAdminScreen> createState() =>
      _ProductDetailAdminScreenState();
}

class _ProductDetailAdminScreenState extends State<ProductDetailAdminScreen> {
  late Future<Product> _productFuture;
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _basePriceController;
  late TextEditingController _minStockController;
  late TextEditingController _maxStockController;
  String? _selectedStatus;

  Future<void> _fetchProductDetails() async {
    try {
      final productApiService = ProductApiService(ApiClient());
      final productFuture = productApiService.getProductById(widget.productId);

      if (mounted) {
        setState(() {
          _productFuture = productFuture;
        });
      }
    } catch (e) {
      print('Error fetching product: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _fetchProductDetails();
    // Initialize controllers
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _basePriceController = TextEditingController();
    _minStockController = TextEditingController();
    _maxStockController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  void _populateControllers(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _basePriceController.text = product.basePrice.toString();
    _minStockController.text = product.minStockLevel.toString();
    _maxStockController.text = product.maxStockLevel.toString();
    _selectedStatus = product.status;
  }

  Future<void> _updateProduct(Product product) async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedProduct = Product(
          id: product.id,
          code: product.code,
          name: _nameController.text,
          description: _descriptionController.text,
          imageUrl: product.imageUrl,
          category: product.category,
          brand: product.brand,
          status: _selectedStatus ?? product.status,
          basePrice: double.parse(_basePriceController.text),
          minStockLevel: int.parse(_minStockController.text),
          maxStockLevel: int.parse(_maxStockController.text),
          views: product.views,
          createdAt: product.createdAt,
          updatedAt: DateTime.now(),
          skus: product.skus,
        );

        // await ProductService().updateProduct(updatedProduct);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditMode = false;
            // _product = Future.value(updatedProduct);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update product: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          FutureBuilder<Product>(
            future: _productFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return _isEditMode
                    ? Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditMode = false;
                              });
                            },
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text('Cancel',
                                style: TextStyle(color: Colors.red)),
                          ),
                          TextButton.icon(
                            onPressed: () => _updateProduct(snapshot.data!),
                            icon: const Icon(Icons.save, color: Colors.green),
                            label: const Text('Save',
                                style: TextStyle(color: Colors.green)),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: () {
                          _populateControllers(snapshot.data!);
                          setState(() {
                            _isEditMode = true;
                          });
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text('Edit',
                            style: TextStyle(color: Colors.blue)),
                      );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading product: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // _productFuture = ProductService().getProductDetail(widget.productId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Product not found'));
          }

          final product = snapshot.data!;
          // Create mock gallery images based on the product ID
          // In a real app, these would come from the API
          final List<String> galleryImages = [];
          galleryImages.add(product.imageUrl);

          // Add some mock gallery images based on product ID
          for (int i = 1; i <= 4; i++) {
            galleryImages.add(product.imageUrl);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _isEditMode
                ? _buildEditForm(product)
                : _buildProductDetail(product),
          );
        },
      ),
    );
  }

  Widget _buildProductDetail(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product header with image
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    size: 50)),
                      )
                    : const Center(child: Icon(Icons.image_outlined, size: 50)),
              ),
            ),
            const SizedBox(width: 24),

            // Product basic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRow('Mã sản phẩm', product.code),
                  _infoRow('Giá cơ  bản', product.formattedPrice),
                  _infoRow('Trạng thái', _buildStatusBadge(product.status)),
                  _infoRow('Danh mục', product.category?.name ?? 'N/A'),
                  _infoRow('Lượt xem', product.views.toString()),
                  _infoRow('Ngày tạo', _formatDate(product.createdAt)),
                  _infoRow('Ngày cập nhật', _formatDate(product.updatedAt)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Description section
        const Text(
          'Mô tả',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Stock information
        const Text(
          'Thông tin tồn kho',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _stockInfoCard(
                  'Định mức tồn thấp nhất', product.minStockLevel.toString()),
              const SizedBox(width: 16),
              _stockInfoCard(
                  'Định mức tồn cao nhất', product.maxStockLevel.toString()),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // SKUs section
        const Text(
          'Biến thể sản phẩm (SKUs)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // SKU cards
        ...(product.skus ?? []).map((sku) => _buildSkuCard(sku)).toList(),
      ],
    );
  }

  Widget _buildEditForm(Product product) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image (non-editable in this implementation)
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50)),
                          )
                        : const Center(
                            child: Icon(Icons.image_outlined, size: 50)),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                        onPressed: () {
                          // Image upload functionality would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Image upload not implemented in this demo'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Product code (non-editable)
          _infoRow('Mã sản phẩm', product.code),

          const SizedBox(height: 16),

          // Editable fields
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên sản phẩm',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a product name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Status dropdown
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Trạng thía',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Published', child: Text('Published')),
              DropdownMenuItem(value: 'Draft', child: Text('Draft')),
              DropdownMenuItem(value: 'Archived', child: Text('Archived')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a status';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Price field
          TextFormField(
            controller: _basePriceController,
            decoration: const InputDecoration(
              labelText: 'Giá cơ bản (VNĐ)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a base price';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Stock level fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minStockController,
                  decoration: const InputDecoration(
                    labelText: 'Định mức tồn cao nhất',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxStockController,
                  decoration: const InputDecoration(
                    labelText: 'Định mức tồn thấp nhất',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // SKUs section (non-editable in this implementation)
          const Text(
            'Biến thể sản phẩm (SKUs)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'SKU management is available in the full version',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 16),

          // Display SKUs in read-only mode
          ...(product.skus ?? [])
              .map((sku) => _buildSkuCard(sku, isReadOnly: true))
              .toList(),
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: value is Widget
                ? Row(
                    mainAxisSize:
                        MainAxisSize.min, // prevent row from expanding
                    children: [value],
                  )
                : Text(value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _stockInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkuCard(Sku sku, {bool isReadOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SKU: ${sku.sku}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (!isReadOnly)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // SKU edit functionality would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('SKU editing not implemented in this demo'),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Barcode: ${sku.barcode}'),
          const SizedBox(height: 16),

          // Price information
          Row(
            children: [
              Expanded(
                child: _skuInfoItem(
                  'Giá bán',
                  sku.formattedPrice,
                  Colors.orange.shade100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _skuInfoItem(
                  'Giá nhập',
                  sku.formattedCostPrice,
                  Colors.green.shade100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _skuInfoItem(
                  'Số lượng tồn',
                  sku.stockOnHand.toString(),
                  Colors.blue.shade100,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Attributes
          const Text(
            'Thuộc tính',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (sku.attributes ?? []).map((attr) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${attr.name}: ${attr.value}',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _skuInfoItem(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
