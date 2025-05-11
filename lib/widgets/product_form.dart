import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/models/dto/create_product_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_sku_dto.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

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

  // Basic product info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedBrand;
  final _basePriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();

  // Attributes and SKUs
  final List<String> _attributeNames = [];
  final List<Map<String, dynamic>> _skus = [];
  final _attributeNameController = TextEditingController();

  // Mock data for dropdowns
  final List<Map<String, String>> _categories = [
    {'id': '67dbbcacd527617c6eeadc9e', 'name': 'Electronics'},
    {'id': '67dbbcacd527617c6eeadc9f', 'name': 'Computers'},
    {'id': '67dbbcacd527617c6eeadca0', 'name': 'Phones'},
  ];

  final List<Map<String, String>> _brands = [
    {'id': '681ef9846d543c6e53cedbb0', 'name': 'Apple'},
    {'id': '681ef9846d543c6e53cedbb1', 'name': 'Samsung'},
    {'id': '681ef9846d543c6e53cedbb2', 'name': 'Dell'},
  ];

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
          });
        }
      }
    } else {
      // Set defaults for new product
      _minStockController.text = '1';
      _maxStockController.text = '20';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _attributeNameController.dispose();
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
      });
    });
  }

  void _removeSku(int index) {
    setState(() {
      _skus.removeAt(index);
    });
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // Convert SKUs to proper format
      final List<Sku> productSkus = _skus.map((skuMap) {
        return Sku(
          id: skuMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          stockQuantity: skuMap['stockQuantity'] ?? 0,
          costPrice: skuMap['costPrice'] ?? 0,
          sellingPrice: skuMap['sellingPrice'] ?? 0,
          stockOnHand: skuMap['stockOnHand'] ?? 0,
          attributeValues: List<String>.from(skuMap['attributeValues'] ?? []),
        );
      }).toList();

      // Create product object
      final product = Product(
        id: widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? '',
        brand: _selectedBrand ?? '',
        basePrice: double.tryParse(_basePriceController.text) ?? 0,
        minStockLevel: int.tryParse(_minStockController.text) ?? 1,
        maxStockLevel: int.tryParse(_maxStockController.text) ?? 20,
        attributeNames: _attributeNames,
        skus: productSkus,
      );

      widget.onSave(product);
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

                  // Product name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên sản phẩm',
                      hintText: 'Nhập tên sản phẩm',
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.red.shade400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên sản phẩm';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Product description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Mô tả sản phẩm',
                      hintText: 'Nhập mô tả sản phẩm',
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.red.shade400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product description';
                      }
                      return null;
                    },
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
                          controller: _attributeNameController,
                          decoration: InputDecoration(
                            labelText: 'Tên thuộc tính',
                            hintText: 'VD: Kích thước, Màu sắc, RAM',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.red.shade400, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
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
                        deleteIcon: const Icon(Icons.close, size: 18),
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
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text(
                  'Lưu sản phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Danh mục',
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
      value: _selectedCategory,
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'],
          child: Text(category['name']!),
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
    );
  }

  Widget _buildBrandDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Thương hiệu',
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
      value: _selectedBrand,
      items: _brands.map((brand) {
        return DropdownMenuItem<String>(
          value: brand['id'],
          child: Text(brand['name']!),
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
    );
  }

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
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập giá cơ bản';
        }
        if (double.tryParse(value) == null) {
          return 'Vui lòng nhập số hợp lệ';
        }
        return null;
      },
    );
  }

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
                    labelText: '${_attributeNames[attrIndex]} Value',
                    hintText:
                        'Enter ${_attributeNames[attrIndex].toLowerCase()} value',
                    border: const OutlineInputBorder(),
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

  Widget _buildSkuNumberField({
    required int index,
    required String field,
    required String label,
    String? prefixText,
  }) {
    final sku = _skus[index];

    return TextFormField(
      initialValue: sku[field]?.toString() ?? '0',
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
        if (field == 'costPrice' || field == 'sellingPrice')
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        else
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
          return 'Required';
        }
        return null;
      },
    );
  }
}
