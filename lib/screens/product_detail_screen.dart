import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/product_api_service.dart';
import 'package:flutter_ecommerce/apis/review_api_service.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/models/sku.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:flutter_ecommerce/widgets/image_gallery.dart';
import 'package:flutter_ecommerce/widgets/product_info_cart.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ecommerce/models/review.dart';

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
  int _currentImageOrder = 0;

  // Thêm biến mới cho phần mô tả có thể mở rộng
  bool _isDescriptionExpanded = false;

  // Thêm biến cho phần đánh giá
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0;
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();

    // Thêm dữ liệu đánh giá mẫu
    _addMockReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Thêm phương thức để tạo dữ liệu đánh giá mẫu
  void _addMockReviews() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _reviewService.addMockReviews(widget.productId);
    });
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productApiService = ProductApiService(ApiClient());
      final product = await productApiService.getProductById(widget.productId);

      // Tạo danh sách hình ảnh từ sản phẩm và các biến thể
      final List<String> galleryImages = [];

      // Thêm hình ảnh chính của sản phẩm
      galleryImages.add(product.imageUrl);

      // Thêm hình ảnh từ các biến thể SKU
      if (product.skus != null && product.skus!.isNotEmpty) {
        for (final sku in product.skus!) {
          if (sku.imageUrl != null &&
              sku.imageUrl!.isNotEmpty &&
              !galleryImages.contains(sku.imageUrl)) {
            galleryImages.add(sku.imageUrl!);
          }
        }
      }

      if (mounted) {
        setState(() {
          _product = product;
          _mockGalleryImages.clear();
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
          _errorMessage = 'Không thể tải thông tin sản phẩm. Vui lòng thử lại.';
        });
      }
      print('Lỗi khi tải sản phẩm: $e');
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
          content: const Text('Đã thêm sản phẩm vào giỏ hàng'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Xem giỏ hàng',
            textColor: Colors.white,
            onPressed: () {
              // context.goNamed(AppRoute.cart.name);
              navigateTo(context, AppRoute.cart.name);
            },
          ),
        ),
      );
    } else {
      navigateTo(context, AppRoute.cart.path);
    }
  }

  // Thêm phương thức để gửi đánh giá
  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
      );
      return;
    }

    // Kiểm tra nếu người dùng đang cố gắng đánh giá mà không đăng nhập
    final isLoggedIn = false;
    if (_userRating > 0 && !isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewService.addReview(
        productId: widget.productId,
        comment: _commentController.text.trim(),
        rating: _userRating,
        isAnonymous: _isAnonymous,
      );

      // Xóa form
      _commentController.clear();
      setState(() {
        _userRating = 0;
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi đánh giá thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Thêm phương thức hiển thị hộp thoại đăng nhập
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text(
          'Bạn cần đăng nhập để đánh giá sản phẩm. Bạn vẫn có thể để lại bình luận với tư cách người dùng ẩn danh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Điều hướng đến trang đăng nhập hoặc hiển thị hộp thoại đăng nhập
              // Đối với demo, chúng ta sẽ chỉ mô phỏng đăng nhập
              _simulateLogin();
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  // Thêm phương thức mô phỏng đăng nhập
  void _simulateLogin() async {
    // Hiển thị hộp thoại đang tải
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Đang đăng nhập...'),
          ],
        ),
      ),
    );

    // Mô phỏng đăng nhập
    // await _authService.login('user@example.com', 'password');

    // Đóng hộp thoại và cập nhật UI
    if (mounted) {
      Navigator.of(context).pop();
      setState(() {
        _isAnonymous = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter Ecommerce',
          style: const TextStyle(
            color: Colors.lightBlue,
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
        mobile: ResponsiveBuilder.isMobile(context) ? _buildBottomBar() : null,
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
            _errorMessage ?? 'Đã xảy ra lỗi',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _fetchProductDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
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
          ImageGallery(
            images: _mockGalleryImages,
            // currentImageOrder: _currentImageOrder,
          ),
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
                const SizedBox(height: 32),
                // Thêm phần đánh giá sản phẩm
                _buildReviewSection(),
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
              child: ImageGallery(
                images: _mockGalleryImages,
              ),
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
                  const SizedBox(height: 32),
                  // Thêm phần đánh giá sản phẩm
                  _buildReviewSection(),
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
                    child: ImageGallery(
                      images: _mockGalleryImages,
                      currentImageOrder: _currentImageOrder,
                    ),
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
                        const SizedBox(height: 32),
                        // Thêm phần đánh giá sản phẩm
                        _buildReviewSection(),
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
    final numberFormat = NumberFormat.decimalPattern(); // uses current locale

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
              numberFormat.format(999),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            Text(
              '| Lượt xem: (${numberFormat.format(_product!.views)}) | Lượt mua: (${numberFormat.format(_product!.views)}) ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // color: colorScheme.primaryContainer,
                color: _selectedSku?.stockOnHand != null &&
                        _selectedSku!.stockOnHand > 0
                    ? Colors.green
                    : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _selectedSku?.stockOnHand != null &&
                        _selectedSku!.stockOnHand > 0
                    ? 'Còn hàng'
                    : 'Hết hàng',
                style: TextStyle(
                  color: Colors.white,
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

                  // Cập nhật hình ảnh được chọn nếu SKU này có hình ảnh
                  if (sku.imageUrl != null && sku.imageUrl!.isNotEmpty) {
                    // Tìm vị trí của hình ảnh này trong thư viện
                    final imageIndex =
                        _mockGalleryImages.indexOf(sku.imageUrl!);
                    if (imageIndex >= 0) {
                      // Nếu tìm thấy, chúng ta có thể cập nhật chỉ mục hình ảnh được chọn
                      // hoặc kích hoạt thư viện hình ảnh để hiển thị hình ảnh này
                      setState(() {
                        _currentImageOrder = imageIndex;
                      });
                    }
                  }
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
                  variantsName ?? 'Không có',
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
        // Phần mô tả có thể mở rộng
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                _product!.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.6,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                _product!.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.6,
                    ),
              ),
              crossFadeState: _isDescriptionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Thêm phương thức xây dựng phần đánh giá sản phẩm
  Widget _buildReviewSection() {
    final numberFormat = NumberFormat.decimalPattern('vi_VN'); // or 'de_DE'
    final totalRating = numberFormat.format(99999);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Text(
          'Đánh giá & Nhận xét (${totalRating})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        _buildReviewForm(),
        const SizedBox(height: 30),
        _buildReviewsList(),
      ],
    );
  }

  // Thêm phương thức xây dựng form đánh giá
  Widget _buildReviewForm() {
    final isLoggedIn = false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viết đánh giá',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Đánh giá của bạn: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                _buildStarRating(),
              ],
            ),
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Bạn phải đăng nhập để đánh giá sản phẩm',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Chia sẻ ý kiến của bạn về sản phẩm này...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isLoggedIn)
                  Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value ?? true;
                          });
                        },
                      ),
                      const Text('Đăng với tư cách ẩn danh'),
                      const SizedBox(width: 16),
                    ],
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Gửi đánh giá'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Thêm phương thức xây dựng đánh giá sao
  Widget _buildStarRating() {
    final isLoggedIn = false;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _userRating = index + 1;
            });
            if (_userRating > 0 && !isLoggedIn) {
              _showLoginDialog();
            }
          },
          child: Icon(
            index < _userRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }

  // Thêm phương thức xây dựng danh sách đánh giá
  Widget _buildReviewsList() {
    return StreamBuilder<List<Review>>(
      stream: _reviewService.getReviewsStreamForProduct(widget.productId),
      initialData: _reviewService.getReviewsForProduct(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child:
                  Text('Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá!'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewItem(review);
          },
        );
      },
    );
  }

  // Thêm phương thức xây dựng mục đánh giá
  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  review.userName?.substring(0, 1).toUpperCase() ?? 'A',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Ẩn danh',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (review.rating > 0)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment),
        ],
      ),
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
            const SizedBox(width: 12),
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
