import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/models/sku.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/widgets/image_gallery.dart';
import 'package:flutter_ecommerce/widgets/product_info_cart.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  Sku? _selectedSku;
  int _quantity = 1;
  bool _isLoading = true;
  String? _errorMessage;
  final List<String> _mockGalleryImages = [];

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productApiService = ProductApiService(ApiClient());
      final product = await productApiService.getProductById(widget.productId);

      // Create mock gallery images based on the product ID
      // In a real app, these would come from the API
      final List<String> galleryImages = [];
      galleryImages.add(product.imageUrl);

      // Add some mock gallery images based on product ID
      for (int i = 1; i <= 4; i++) {
        galleryImages.add(product.imageUrl);
      }

      if (mounted) {
        setState(() {
          _product = product;
          _mockGalleryImages.addAll(galleryImages);
          final sortedSkus = [...(product.skus ?? [])]
            ..sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
          _selectedSku = sortedSkus.isNotEmpty ? sortedSkus.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load product details. Please try again.';
        });
      }
      print('Error fetching product: $e');
    }
  }

  void _addProductToCart({bool isBuyNow = false}) {
    if (_product == null || _selectedSku == null) {
      return;
    }

    ref.read(cartProvider.notifier).addCartItem(
          CartItem(
            id: DateTime.now().toString(),
            quantity: _quantity,
            price: _selectedSku!.sellingPrice,
            product: _product!,
            isChecked: isBuyNow,
            sku: _selectedSku,
          ),
        );

    if (!isBuyNow) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product added to cart'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              context.goNamed(AppRoute.cart.name);
            },
          ),
        ),
      );
    } else {
      context.go(AppRoute.cart.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _product != null ? _product!.name : 'Product Details',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Share product
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : ResponsiveBuilder(
                  mobile: _buildMobileLayout(),
                  tablet: _buildTabletLayout(),
                  desktop: _buildDesktopLayout(),
                ),
      bottomNavigationBar: ResponsiveBuilder(
        mobile: _buildBottomBar(),
        tablet: null,
        desktop: null, // No bottom bar on desktop
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'An error occurred',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _fetchProductDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile layout - stacked vertically
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          ImageGallery(images: _mockGalleryImages),

          // Product info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const SizedBox(height: 24),
                _buildVariantSelector(),
                const SizedBox(height: 24),
                _buildQuantitySelector(),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 80), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tablet layout - image on top, info below with more horizontal space
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image gallery
            SizedBox(
              height: 400,
              child: ImageGallery(images: _mockGalleryImages),
            ),

            // Product info in a card
            const SizedBox(height: 24),
            ProductInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: 24),
                  _buildVariantSelector(),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop layout - side by side with image on left, info on right
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image gallery
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 600,
                    child: ImageGallery(images: _mockGalleryImages),
                  ),
                ),

                const SizedBox(width: 32),

                // Right side - Product info
                Expanded(
                  flex: 5,
                  child: ProductInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductInfo(),
                        const SizedBox(height: 32),
                        _buildVariantSelector(),
                        const SizedBox(height: 32),
                        _buildQuantitySelector(),
                        const SizedBox(height: 32),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        _buildDesktopActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _product!.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              '999', // Mock rating
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Text(
              '1999', // Mock review count
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'In Stock',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _selectedSku?.formattedPrice ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 12),
            // Mock original price for discount display
            if (_selectedSku != null && true)
              Text(
                _selectedSku!.formattedPrice,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            const SizedBox(width: 8),
            // Mock discount percentage
            if (_selectedSku != null && true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-20%',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariantSelector() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_product?.skus == null || _product!.skus!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân loại:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _product!.skus!.map((sku) {
            final isSelected = _selectedSku?.id == sku.id;
            final variantsName =
                sku.attributes?.map((att) => att.value).join(' - ');

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSku = sku;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                ),
                child: Text(
                  variantsName ?? '',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'Số lượng:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: _quantity > 1 ? colorScheme.primary : Colors.grey,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _product!.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _addProductToCart(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.flash_on_outlined, size: 20),
                  label: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _addProductToCart(isBuyNow: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActionButtons() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              label: const Text(
                'Thêm vào giỏ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _addProductToCart(),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flash_on_outlined, size: 20),
              label: const Text(
                'Mua ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _addProductToCart(isBuyNow: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
