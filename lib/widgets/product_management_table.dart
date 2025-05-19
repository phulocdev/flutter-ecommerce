import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:flutter_ecommerce/widgets/product_form.dart';
import 'package:go_router/go_router.dart';

class ProductManagementTable extends StatefulWidget {
  final List<Product> products;
  final Function(String)? onDelete;
  final Function(Product)? onEdit;
  final ScrollController? scrollController; // Add scroll controller parameter

  const ProductManagementTable({
    super.key,
    required this.products,
    this.onDelete,
    this.onEdit,
    this.scrollController, // Make it optional
  });

  @override
  State<ProductManagementTable> createState() => _ProductManagementTableState();
}

class _ProductManagementTableState extends State<ProductManagementTable> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Table header
                Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      _buildHeaderCell('Mã sản phẩm', 200),
                      _buildHeaderCell('Sản phẩm', 400),
                      _buildHeaderCell('Mô tả', 400),
                      _buildHeaderCell('Giá', 150),
                      _buildHeaderCell('Trạng thái', 120),
                      _buildHeaderCell('Ngày tạo', 120),
                      _buildHeaderCell('Ngày cập nhật', 150),
                      _buildHeaderCell('Hành động', 120),
                    ],
                  ),
                ),

                // Table body with vertical scrolling - use the passed scroll controller
                Expanded(
                  child: ListView.builder(
                    controller: widget
                        .scrollController, // Use the passed scroll controller
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to product detail page
                          // context.go(
                          //   '${AppRoute.productManagement.path}/${product.id}',
                          // );
                          navigateTo(context,
                              '${AppRoute.productManagement.path}/${product.id}');
                        },
                        onHover: (isHovered) {
                          setState(() {
                            hoveredIndex = isHovered ? index : null;
                          });
                        },
                        child: Container(
                          height: 100, // Increased row height
                          decoration: BoxDecoration(
                            color: hoveredIndex == index
                                ? Colors.blue.shade50
                                : Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildCell(
                                Text(
                                  product.code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                150,
                              ),
                              _buildCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: product.imageUrl != null
                                            ? Image.network(
                                                product.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(Icons
                                                        .image_not_supported_outlined),
                                              )
                                            : const Icon(Icons.image_outlined),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: SizedBox(
                                        width: 400,
                                        child: Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                400,
                              ),
                              _buildCell(
                                SizedBox(
                                  width: 230,
                                  child: Text(
                                    product.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                      height: 1.5, // Increased line height
                                    ),
                                  ),
                                ),
                                400,
                              ),
                              _buildCell(
                                Text(
                                  product.formattedPrice,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                200,
                              ),
                              _buildCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(product.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    product.status,
                                    style: TextStyle(
                                      color: _getStatusColor(product.status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                120,
                              ),
                              _buildCell(
                                Text(
                                  product.createdAt != null
                                      ? '${product.createdAt!.day}/${product.createdAt!.month}/${product.createdAt!.year}'
                                      : '-',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                120,
                              ),
                              _buildCell(
                                Text(
                                  product.updatedAt != null
                                      ? '${product.updatedAt!.day}/${product.updatedAt!.month}/${product.updatedAt!.year}'
                                      : '-',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                150,
                              ),
                              _buildCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Chỉnh sửa sản phẩm',
                                      onPressed: () {
                                        navigateTo(
                                          context,
                                          AppRoute.productDetailAdmin.path,
                                          extra: product,
                                        );
                                        // // Navigate to product form with product data
                                        // Navigator.of(context).push(
                                        //   MaterialPageRoute(
                                        //     builder: (context) => Scaffold(
                                        //       appBar: AppBar(
                                        //         title: const Text(
                                        //             'Chỉnh sửa sản phẩm'),
                                        //       ),
                                        //       body: SingleChildScrollView(
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.all(
                                        //               16.0),
                                        //           child: ProductForm(
                                        //             product:
                                        //                 _convertToCreateProductDto(
                                        //                     product),
                                        //             onSave: (updatedProduct) {
                                        //               if (widget.onEdit !=
                                        //                   null) {
                                        //                 widget.onEdit!(product);
                                        //               }
                                        //             },
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      tooltip: 'Xóa sản phẩm',
                                      onPressed: () => _showDeleteConfirmation(
                                          context, product.id),
                                    ),
                                  ],
                                ),
                                120,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to convert Product to CreateProductDto
  // This is a simplified conversion - you may need to adjust based on your actual models
  dynamic _convertToCreateProductDto(Product product) {
    return {
      'name': product.name,
      'description': product.description,
      'category': product.category?.id ?? '',
      'brand': product.brand?.id ?? '',
      'basePrice': product.basePrice,
      'minStockLevel': 1,
      'maxStockLevel': 20,
      'imageUrl': product.imageUrl,
      // Add other fields as needed
    };
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCell(Widget content, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: content,
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Đang xóa sản phẩm...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              // Simulate API call with Future.delayed
              Future.delayed(const Duration(seconds: 2), () {
                // Call the API service to delete the product
                final productApiService = ProductApiService(ApiClient());

                try {
                  // This would be your actual API call
                  // productApiService.deleteProduct(productId);

                  // For now, just call the onDelete callback
                  if (widget.onDelete != null) {
                    widget.onDelete!(productId);
                  }

                  // Show success message
                  if (context.mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Xóa sản phẩm thành công'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // Show error message
                  if (context.mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Lỗi khi xóa sản phẩm: $e'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
}
