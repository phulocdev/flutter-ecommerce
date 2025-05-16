import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/apis/brand_api_service.dart';
import 'package:flutter_ecommerce/apis/category_api_service.dart';
import 'package:flutter_ecommerce/apis/image_upload_service.dart';
import 'package:flutter_ecommerce/apis/image_upload_service_v2.dart';
import 'package:flutter_ecommerce/models/brand.dart';
import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/models/dto/create_product_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_sku_dto.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/screens/product_management_screen.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// Cross-platform image widget that works on both web and mobile
class CrossPlatformImage extends StatelessWidget {
  final dynamic imageSource; // Can be File or Uint8List
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CrossPlatformImage({
    Key? key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb) {
      // For web, use Image.memory with Uint8List
      if (imageSource is Uint8List) {
        imageWidget = Image.memory(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        // Fallback for web if not Uint8List
        imageWidget = Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }
    } else {
      // For mobile, use Image.file
      if (imageSource is File) {
        imageWidget = Image.file(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        // Fallback for mobile if not File
        imageWidget = Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class ProductForm extends StatefulWidget {
  final CreateProductDto? product;
  final Function(CreateProductDto) onSave;

  const ProductForm({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _attributeFocusNode = FocusNode();
  late List<Category> _categoryList = [];
  late List<Brand> _brandList = [];

  // Basic product info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedBrand;
  final _basePriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  bool _isSaving = false;

  // Image handling - can be File (mobile) or Uint8List (web)
  dynamic _productImage;
  final Map<int, dynamic> _skuImages = {};
  final ImagePicker _imagePicker = ImagePicker();

  // Map to store controllers for SKUs
  final Map<String, TextEditingController> _skuControllers = {};

  // Attributes and SKUs
  final List<String> _attributeNames = [];
  final List<Map<String, dynamic>> _skus = [];
  final _attributeNameController = TextEditingController();

  // Generate a unique key for each SKU field
  String _getSkuFieldKey(int index, String field) {
    return 'sku_${index}_${field}';
  }

  // Get or create a controller for a SKU field
  TextEditingController _getSkuController(
      int index, String field, dynamic initialValue) {
    final key = _getSkuFieldKey(index, field);
    if (!_skuControllers.containsKey(key)) {
      _skuControllers[key] = TextEditingController(
        text: initialValue?.toString() ?? '0',
      );
    }
    return _skuControllers[key]!;
  }

  Future<void> _fetchBrandAndCategoriesList() async {
    try {
      final brandApiService = BrandApiService(ApiClient());
      final categoriesApiService = CategoryApiService(ApiClient());
      final brandList = await brandApiService.getBrands();
      final categoryList = await categoriesApiService.getCategories();
      setState(() {
        _brandList = brandList;
        _categoryList = categoryList;
      });
    } catch (e) {
      print('Error fetching category and brand list: $e');
    }
  }

  Future<void> _pickProductImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            // For web, read as bytes
            pickedFile.readAsBytes().then((bytes) {
              _productImage = bytes;
            });
          } else {
            // For mobile, use File
            _productImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickSkuImage(int index) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, read as bytes
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _skuImages[index] = bytes;
            });
          });
        } else {
          // For mobile, use File
          setState(() {
            _skuImages[index] = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      print('Error picking SKU image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking SKU image: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize with existing product data if editing
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _selectedCategory = widget.product!.category;
      _selectedBrand = widget.product!.brand;
      _basePriceController.text = widget.product!.basePrice.toString();
      _minStockController.text = widget.product!.minStockLevel.toString();
      _maxStockController.text = widget.product!.maxStockLevel.toString();

      // Initialize attributes and SKUs
      _attributeNames.addAll(widget.product!.attributeNames ?? []);

      // Initialize SKUs if available
      if (widget.product!.skus != null) {
        for (var sku in widget.product!.skus!) {
          _skus.add({
            'stockQuantity': sku.stockQuantity,
            'costPrice': sku.costPrice,
            'sellingPrice': sku.sellingPrice,
            'stockOnHand': sku.stockOnHand,
            'attributeValues': sku.attributeValues,
            'imageUrl': sku.imageUrl,
          });
        }
      }
    } else {
      // Set defaults for new product
      _minStockController.text = '1';
      _maxStockController.text = '20';
    }

    _fetchBrandAndCategoriesList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _attributeNameController.dispose();
    _attributeFocusNode.dispose();

    // Dispose all SKU controllers
    for (var controller in _skuControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _addAttributeName() {
    final name = _attributeNameController.text.trim();
    if (name.isNotEmpty && !_attributeNames.contains(name)) {
      setState(() {
        _attributeNames.add(name);
        _attributeNameController.clear();
      });
    }
    _attributeFocusNode.requestFocus();
  }

  void _removeAttributeName(String name) {
    setState(() {
      _attributeNames.remove(name);

      // Remove attribute values from SKUs
      for (var sku in _skus) {
        final index = _attributeNames.indexOf(name);
        if (index >= 0 && sku['attributeValues'] != null) {
          final attributeValues = List<String>.from(sku['attributeValues']);
          if (index < attributeValues.length) {
            attributeValues.removeAt(index);
            sku['attributeValues'] = attributeValues;
          }
        }
      }
    });
  }

  void _addSku() {
    setState(() {
      _skus.add({
        'stockQuantity': 0,
        'costPrice': 0,
        'sellingPrice': 0,
        'stockOnHand': 0,
        'attributeValues': List<String>.filled(_attributeNames.length, ''),
        'imageUrl': null,
      });
    });
  }

  void _removeSku(int index) {
    // Clean up controllers for this SKU
    for (final field in ['costPrice', 'sellingPrice', 'stockOnHand']) {
      final key = _getSkuFieldKey(index, field);
      _skuControllers[key]?.dispose();
      _skuControllers.remove(key);
    }

    // Remove SKU image if exists
    _skuImages.remove(index);

    setState(() {
      _skus.removeAt(index);
    });

    // Update keys for remaining SKUs
    for (int i = index; i < _skus.length; i++) {
      for (final field in ['costPrice', 'sellingPrice', 'stockOnHand']) {
        final oldKey = _getSkuFieldKey(i + 1, field);
        final newKey = _getSkuFieldKey(i, field);
        if (_skuControllers.containsKey(oldKey)) {
          _skuControllers[newKey] = _skuControllers[oldKey]!;
          _skuControllers.remove(oldKey);
        }
      }

      // Update image keys
      if (_skuImages.containsKey(i + 1)) {
        _skuImages[i] = _skuImages[i + 1];
        _skuImages.remove(i + 1);
      }
    }
  }

  void _updateSkuAttributeValue(
      int skuIndex, int attributeIndex, String value) {
    setState(() {
      final attributeValues =
          List<String>.from(_skus[skuIndex]['attributeValues'] ?? []);

      // Ensure the list is long enough
      while (attributeValues.length <= attributeIndex) {
        attributeValues.add('');
      }

      attributeValues[attributeIndex] = value;
      _skus[skuIndex]['attributeValues'] = attributeValues;
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final imageUploadService = ImageUploadApiServiceV2();

      // Convert SKUs to proper format
      final List<CreateSkuDto> productSkus =
          await Future.wait(_skus.map((skuMap) async {
        // Get values from controllers for this SKU
        final index = _skus.indexOf(skuMap);
        String? imageUrl;

        // Handle SKU image upload
        if (_skuImages.containsKey(index)) {
          if (kIsWeb && _skuImages[index] is Uint8List) {
            try {
              // Upload the SKU image using the new service
              imageUrl = await imageUploadService.apiClient.uploadImage(
                imageBytes: _skuImages[index],
                folderName: 'products-flutter',
                fileName:
                    'sku_image_${index}_${DateTime.now().millisecondsSinceEpoch}',
                // Let the service detect the mime type automatically
              );
            } catch (e) {
              print('Failed to upload SKU image: $e');
              // Handle upload error
            }
          } else if (!kIsWeb && _skuImages[index] is File) {
            // For mobile, you'd need to read the file into bytes first
            final File file = _skuImages[index] as File;
            final bytes = await file.readAsBytes();
            try {
              imageUrl = await imageUploadService.apiClient.uploadImage(
                imageBytes: bytes,
                folderName: 'products-flutter',
                fileName:
                    'sku_image_${index}_${DateTime.now().millisecondsSinceEpoch}',
              );
            } catch (e) {
              print('Failed to upload SKU image: $e');
              // Handle upload error
            }
          }
        }

        // Get other SKU fields
        final costPriceKey = _getSkuFieldKey(index, 'costPrice');
        final sellingPriceKey = _getSkuFieldKey(index, 'sellingPrice');
        final stockOnHandKey = _getSkuFieldKey(index, 'stockOnHand');

        final costPrice =
            double.tryParse(_skuControllers[costPriceKey]?.text ?? '0') ?? 0;
        final sellingPrice =
            double.tryParse(_skuControllers[sellingPriceKey]?.text ?? '0') ?? 0;
        final stockOnHand =
            int.tryParse(_skuControllers[stockOnHandKey]?.text ?? '0') ?? 0;

        return CreateSkuDto(
          stockQuantity: skuMap['stockQuantity'] ?? 0,
          costPrice: costPrice,
          sellingPrice: sellingPrice,
          stockOnHand: stockOnHand,
          attributeValues: List<String>.from(skuMap['attributeValues'] ?? []),
          imageUrl: imageUrl,
        );
      }));

      // Handle product image based on platform
      String? productImageUrl;
      if (_productImage != null && kIsWeb) {
        try {
          // Upload the product image using the new service
          productImageUrl = await imageUploadService.apiClient.uploadImage(
            imageBytes: _productImage,
            folderName: 'products-flutter',
            fileName: 'product_image_${DateTime.now().millisecondsSinceEpoch}',
          );

          print('>>>>> ${productImageUrl}');
        } catch (e) {
          print('Failed to upload product image: $e');
          // Handle upload error, perhaps show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to upload product image: ${e.toString()}')),
          );
        }
      } else if (!kIsWeb && _productImage is File) {
        // For mobile, read the file into bytes first
        final File file = _productImage as File;
        final bytes = await file.readAsBytes();
        try {
          productImageUrl = await imageUploadService.apiClient.uploadImage(
            imageBytes: bytes,
            folderName: 'products-flutter',
            fileName: 'product_image_${DateTime.now().millisecondsSinceEpoch}',
          );
        } catch (e) {
          print('Failed to upload product image: $e');
          // Handle upload error
        }
      }

      // Create product object
      final product = CreateProductDto(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? '',
        brand: _selectedBrand ?? '',
        basePrice: double.tryParse(_basePriceController.text) ?? 0,
        minStockLevel: int.tryParse(_minStockController.text) ?? 1,
        maxStockLevel: int.tryParse(_maxStockController.text) ?? 20,
        attributeNames: _attributeNames,
        skus: productSkus,
        imageUrl: productImageUrl,
      );

      try {
        await widget.onSave(product);
        if (context.mounted) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => ProductManagementScreen()));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm sản phẩm thành công'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu sản phẩm thất bại: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveBuilder.isDesktop(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic product information section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin cơ bản',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Product image and basic info
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image upload
                        _buildProductImageUpload(),
                        const SizedBox(width: 24),

                        // Product name and description
                        Expanded(
                          child: Column(
                            children: [
                              _buildProductNameField(),
                              const SizedBox(height: 16),
                              _buildProductDescriptionField(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildProductImageUpload(),
                        const SizedBox(height: 16),
                        _buildProductNameField(),
                        const SizedBox(height: 16),
                        _buildProductDescriptionField(),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Category and Brand in a row for desktop, column for mobile
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(child: _buildCategoryDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBrandDropdown()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildCategoryDropdown(),
                        const SizedBox(height: 16),
                        _buildBrandDropdown(),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Price and stock in a row for desktop, column for mobile
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(child: _buildBasePriceField()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _buildMinStockField()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildMaxStockField()),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildBasePriceField(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildMinStockField()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMaxStockField()),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Product attributes section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thuộc tính sản phẩm',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Xác định các thuộc tính như Kích thước, Màu sắc, RAM, v.v. cho các biến thể sản phẩm',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Add attribute name field
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: _attributeFocusNode,
                          controller: _attributeNameController,
                          onFieldSubmitted: (_) => _addAttributeName(),
                          decoration: InputDecoration(
                            labelText: 'Tên thuộc tính',
                            hintText: 'VD: Kích thước, Màu sắc, RAM',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red.shade400,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _addAttributeName,
                        child: const Text('Thêm thuộc tính'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Display attribute names as chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attributeNames.map((name) {
                      return Chip(
                        label: Text(name),
                        backgroundColor: Colors.blue,
                        labelStyle: TextStyle(color: Colors.white),
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                        onDeleted: () => _removeAttributeName(name),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // SKUs section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biến thể sản phẩm (SKUs)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _attributeNames.isEmpty ? null : _addSku,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm biến thể'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Xác định các biến thể khác nhau của sản phẩm',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  if (_attributeNames.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.amber.shade800),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Thêm ít nhất một thuộc tính trước khi tạo biến thể',
                              style: TextStyle(color: Colors.amber.shade800),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_skus.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade800),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Nhấp "Thêm biến thể" để tạo biến thể sản phẩm đầu tiên',
                              style: TextStyle(color: Colors.blue.shade800),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _skus.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return _buildSkuItem(index);
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save button
          Center(
            child: SizedBox(
                width: isDesktop ? 200 : double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : _saveProduct, // disable button when saving
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Lưu sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isSaving) ...[
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProductImageUpload() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _productImage != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: _productImage != null
          ? Stack(
              children: [
                // Use CrossPlatformImage instead of Image.file
                CrossPlatformImage(
                  imageSource: _productImage,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _productImage = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _pickProductImage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thêm ảnh sản phẩm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Tên sản phẩm',
        hintText: 'Nhập tên sản phẩm',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tên sản phẩm';
        }
        return null;
      },
    );
  }

  Widget _buildProductDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Mô tả sản phẩm',
        hintText: 'Nhập mô tả sản phẩm',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a product description';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedCategory != null
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.category_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Chọn danh mục',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            isExpanded: true,
            value: _selectedCategory,
            items: _categoryList.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn danh mục';
              }
              return null;
            },
            dropdownColor: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thương hiệu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedBrand != null
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.business_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Chọn thương hiệu',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            isExpanded: true,
            value: _selectedBrand,
            items: _brandList.map((brand) {
              return DropdownMenuItem<String>(
                value: brand.id,
                child: Text(
                  brand.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBrand = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn thương hiệu';
              }
              return null;
            },
            dropdownColor: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }

  // Standard Base Price Field without custom formatting
  Widget _buildBasePriceField() {
    return TextFormField(
      controller: _basePriceController,
      decoration: InputDecoration(
        labelText: 'Giá cơ bản',
        prefixText: '₫ ',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập giá cơ bản';
        }

        final numericValue = double.tryParse(value);
        if (numericValue == null || numericValue <= 0) {
          return 'Vui lòng nhập số hợp lệ';
        }

        return null;
      },
    );
  }

  // Standard Min Stock Field without custom formatting
  Widget _buildMinStockField() {
    return TextFormField(
      controller: _minStockController,
      decoration: InputDecoration(
        labelText: 'Tồn kho tối thiểu',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bắt buộc';
        }
        return null;
      },
    );
  }

  // Standard Max Stock Field without custom formatting
  Widget _buildMaxStockField() {
    return TextFormField(
      controller: _maxStockController,
      decoration: InputDecoration(
        labelText: 'Tồn kho tối đa',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bắt buộc';
        }
        return null;
      },
    );
  }

  Widget _buildSkuItem(int index) {
    final sku = _skus[index];
    final bool isDesktop = ResponsiveBuilder.isDesktop(context);

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Biến thể #${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeSku(index),
                  tooltip: 'Remove variant',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // SKU Image and attributes in a row for desktop
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SKU Image
                  _buildSkuImageUpload(index),
                  const SizedBox(width: 24),

                  // Attribute values
                  Expanded(
                    child: Column(
                      children:
                          List.generate(_attributeNames.length, (attrIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextFormField(
                            initialValue: sku['attributeValues'] != null &&
                                    sku['attributeValues'].length > attrIndex
                                ? sku['attributeValues'][attrIndex]
                                : '',
                            decoration: InputDecoration(
                              labelText:
                                  'Thuộc tính ${_attributeNames[attrIndex]}',
                              hintText:
                                  'Nhập giá trị cho thuộc tính ${_attributeNames[attrIndex].toLowerCase()}',
                              border: const OutlineInputBorder(), // Default
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.5),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              _updateSkuAttributeValue(index, attrIndex, value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  // SKU Image
                  _buildSkuImageUpload(index),
                  const SizedBox(height: 16),

                  // Attribute values
                  ...List.generate(_attributeNames.length, (attrIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        initialValue: sku['attributeValues'] != null &&
                                sku['attributeValues'].length > attrIndex
                            ? sku['attributeValues'][attrIndex]
                            : '',
                        decoration: InputDecoration(
                          labelText: 'Thuộc tính ${_attributeNames[attrIndex]}',
                          hintText:
                              'Nhập giá trị cho thuộc tính ${_attributeNames[attrIndex].toLowerCase()}',
                          border: const OutlineInputBorder(), // Default
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 198, 198, 198),
                                width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          _updateSkuAttributeValue(index, attrIndex, value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ],
              ),

            const SizedBox(height: 16),

            // Price and stock fields
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildSkuNumberField(
                      index: index,
                      field: 'costPrice',
                      label: 'Giá nhập',
                      prefixText: '₫ ',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSkuNumberField(
                      index: index,
                      field: 'sellingPrice',
                      label: 'Giá bán',
                      prefixText: '₫ ',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSkuNumberField(
                      index: index,
                      field: 'stockOnHand',
                      label: 'Tồn kho',
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildSkuNumberField(
                    index: index,
                    field: 'costPrice',
                    label: 'Giá nhập',
                    prefixText: '₫ ',
                  ),
                  const SizedBox(height: 16),
                  _buildSkuNumberField(
                    index: index,
                    field: 'sellingPrice',
                    label: 'Giá bán',
                    prefixText: '₫ ',
                  ),
                  const SizedBox(height: 16),
                  _buildSkuNumberField(
                    index: index,
                    field: 'stockOnHand',
                    label: 'Tồn kho',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkuImageUpload(int index) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _skuImages[index] != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: _skuImages[index] != null
          ? Stack(
              children: [
                // Use CrossPlatformImage instead of Image.file
                CrossPlatformImage(
                  imageSource: _skuImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _skuImages.remove(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: () => _pickSkuImage(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 36,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm ảnh biến thể',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Standard SKU Number Field without custom formatting
  Widget _buildSkuNumberField({
    required int index,
    required String field,
    required String label,
    String? prefixText,
  }) {
    final sku = _skus[index];
    final initialValue = sku[field]?.toString() ?? '0';

    // Get or create a controller for this field
    final controller = _getSkuController(index, field, initialValue);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        setState(() {
          if (field == 'costPrice' || field == 'sellingPrice') {
            sku[field] = double.tryParse(value) ?? 0;
          } else {
            sku[field] = int.tryParse(value) ?? 0;
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bắt buộc';
        }
        return null;
      },
    );
  }
}
