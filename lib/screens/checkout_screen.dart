import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/apis/auth_api_service.dart';
import 'package:flutter_ecommerce/apis/coupon_api_service.dart';
import 'package:flutter_ecommerce/apis/order_api_service.dart';
import 'package:flutter_ecommerce/models/cart_item.dart';
import 'package:flutter_ecommerce/models/dto/create_order_dto.dart';
import 'package:flutter_ecommerce/models/dto/register_for_guest_request.dto.dart';
import 'package:flutter_ecommerce/models/dto/validate_coupon_response.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  String paymentMethod = 'cod';
  CouponInfo? _appliedCoupon;
  bool _isValidatingCoupon = false;
  String? _couponError;
  Timer? _debounce;

  final _apiClient = ApiClient();
  final _tokenService = TokenService();
  late final AuthApiService _authApiService =
      AuthApiService(_apiClient, _tokenService);
  late final OrderApiService _orderApiService = OrderApiService(_apiClient);
  late final CouponApiService _couponApiService = CouponApiService(_apiClient);

  @override
  void initState() {
    super.initState();
    final account = ref.read(authProvider);
    if (account != null) {
      _nameController.text = account.fullName;
      _emailController.text = account.email;
      _phoneNumberController.text = account.phoneNumber;
      _addressController.text = account.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _couponController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _validateCoupon(int subTotal) async {
    final couponCode = _couponController.text.trim().toUpperCase();
    if (couponCode.isEmpty) {
      setState(() {
        _couponError = 'Vui lòng nhập mã giảm giá';
      });
      return;
    }

    setState(() {
      _isValidatingCoupon = true;
      _couponError = null;
    });

    try {
      final response =
          await _couponApiService.validateCoupon(couponCode, subTotal);

      // Trường hợp không hợp lệ
      if (!response.valid) {
        setState(() {
          _couponError = response.message ?? 'Mã giảm giá không hợp lệ';
          _appliedCoupon = null;
          _isValidatingCoupon = false;
        });
        return;
      }

      final coupon = response.coupon!;

      // Kiểm tra giá trị đơn hàng có đủ điều kiện để áp dụng giảm giá
      if (coupon.discountAmount > subTotal) {
        setState(() {
          _couponError =
              'Mã giảm giá không áp dụng cho đơn hàng có giá trị thấp hơn ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(coupon.discountAmount)}';
          _appliedCoupon = null;
          _isValidatingCoupon = false;
        });
        return;
      }

      // Trường hợp hợp lệ
      setState(() {
        _appliedCoupon = coupon;
        _couponError = null;
        _isValidatingCoupon = false;
      });
    } catch (e) {
      setState(() {
        _couponError = 'Không thể xác thực mã giảm giá: $e';
        _appliedCoupon = null;
        _isValidatingCoupon = false;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
      _couponError = null;
    });
  }

  void _submitOrder() async {
    final account = ref.read(authProvider);

    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // KH da dang nhap
        String? accountId = account?.id;

        // KH vang Lai
        if (account == null) {
          final registerDto = RegisterForGuestRequestDto(
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              fullName: _nameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim());

          final registerRes =
              await _authApiService.registerForGuest(registerDto);
          accountId = registerRes.data.id;
        }

        final cartItems =
            ref.read(cartProvider).where((item) => item.isChecked);
        final subTotal = cartItems.fold(
            0, (sum, item) => sum + (item.quantity * item.price).toInt());

        // Calculate shipping cost
        final shippingCost = 30000;

        // Apply coupon discount if valid
        final discountAmount =
            _appliedCoupon != null ? _appliedCoupon!.discountAmount : 0;

        // Calculate final total price
        final totalPrice = subTotal + shippingCost - discountAmount;

        final createOrderDto = CreateOrderRequestDto(
          items: cartItems
              .map((item) => OrderItem(
                  sku: item.sku!.id,
                  productId: item.product.id,
                  quantity: item.quantity,
                  costPrice: item.sku!.costPrice,
                  sellingPrice: item.price))
              .toList(),
          itemCount: cartItems.length,
          discountAmount: discountAmount,
          userId: accountId,
          totalPrice: totalPrice,
          paymentMethod: paymentMethod == 'cod' ? 0 : 1,
          shippingInfo: ShippingInfo(
            name: _nameController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            address: _addressController.text,
          ),
          couponCode:
              _appliedCoupon?.code, // Add coupon code to order if applied
        );

        final res = await _orderApiService.create(createOrderDto);
        final newOrder = res.data;
        ref
            .read(cartProvider.notifier)
            .removeCartItems(cartItems.map((item) => item.id).toList());

        if (context.mounted) {
          Navigator.pop(context);
          navigateTo(context, AppRoute.paymentSuccess.path,
              extra: newOrder.code);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Lỗi'),
              content: Text('Không thể đặt hàng: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(int subTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mã giảm giá'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_appliedCoupon == null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]')),
                            LengthLimitingTextInputFormatter(5),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Nhập mã giảm giá',
                            prefixIcon: Icon(Icons.discount,
                                color: Theme.of(context).primaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            errorText: _couponError,
                            hintText: 'Nhập mã 5 ký tự',
                          ),
                          onChanged: (value) {
                            // Clear error when typing
                            if (_couponError != null) {
                              setState(() {
                                _couponError = null;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isValidatingCoupon
                            ? null
                            : () => _validateCoupon(subTotal),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(100, 56),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isValidatingCoupon
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Áp dụng'),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mã giảm giá: ${_appliedCoupon!.code}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Giảm: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_appliedCoupon!.discountAmount)}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_appliedCoupon!.remainingUsage > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Còn lại: ${_appliedCoupon!.remainingUsage} lần sử dụng',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _removeCoupon,
                            icon: const Icon(Icons.close),
                            label: const Text('Xóa'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Phương thức thanh toán'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Divider(height: 1, color: Colors.grey.shade200),
              RadioListTile<String>(
                onChanged: null,
                title: Row(
                  children: [
                    Icon(Icons.account_balance,
                        color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    const Text('Chuyển khoản ngân hàng'),
                  ],
                ),
                value: 'bank_transfer',
                groupValue: paymentMethod,
                // onChanged: (value) => setState(() => paymentMethod = value!),
                activeColor: Theme.of(context).primaryColor,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              RadioListTile<String>(
                selected: true,
                title: Row(
                  children: [
                    Icon(Icons.money, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    const Text('Thanh toán khi nhận hàng (COD)'),
                  ],
                ),
                value: 'cod',
                groupValue: paymentMethod,
                onChanged: (value) => setState(() => paymentMethod = value!),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(List<CartItem> cartItems) {
    final subTotal = cartItems.fold(
        0, (sum, item) => sum + (item.quantity * item.price).toInt());

    // Calculate shipping cost
    final shippingCost = 30000;

    // Apply coupon discount if valid
    final discountAmount =
        _appliedCoupon != null ? _appliedCoupon!.discountAmount : 0;

    // Calculate final total
    final totalAmount = subTotal + shippingCost - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tóm tắt đơn hàng'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: item.product.imageUrl != null
                                  ? Image.network(
                                      item.product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child:
                                              Icon(Icons.image_not_supported),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(Icons.image),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'vi_VN',
                                    symbol: 'đ',
                                    decimalDigits: 0,
                                  ).format(item.price),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Số lượng: ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Total Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: 'đ',
                                  decimalDigits: 0,
                                ).format(item.price * item.quantity),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                Divider(color: Colors.grey.shade300),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính'),
                      Text(NumberFormat.currency(
                              locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
                          .format(subTotal)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phí vận chuyển'),
                      Text(NumberFormat.currency(
                              locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
                          .format(shippingCost)),
                    ],
                  ),
                ),
                if (_appliedCoupon != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Giảm giá (${_appliedCoupon!.code})',
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          '- ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(discountAmount)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                Divider(color: Colors.grey.shade300),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        NumberFormat.currency(
                                locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
                            .format(totalAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final selectedCartItems =
        cartItems.where((item) => item.isChecked).toList();

    final subTotal = selectedCartItems.fold(
        0, (sum, item) => sum + (item.quantity * item.price).toInt());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thông tin giao hàng'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Họ và tên',
                            icon: Icons.person,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập tên'
                              : null,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Email',
                            icon: Icons.email,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || !value.contains('@')
                                  ? 'Email không hợp lệ'
                                  : null,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Số điện thoại',
                            icon: Icons.phone,
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value != null &&
                                !RegExp(r'^(84|0[3|5|7|8|9])[0-9]{8}$')
                                    .hasMatch(value)) {
                              return 'Vui lòng nhập số điện thoại hợp lệ';
                            }
                            return null;
                          },
                          controller: _phoneNumberController,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Địa chỉ nhận hàng',
                            icon: Icons.location_on,
                          ),
                          maxLines: 2,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập địa chỉ'
                              : null,
                          controller: _addressController,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildCouponSection(subTotal),
                _buildPaymentMethodSelector(),
                _buildOrderSummary(selectedCartItems),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Xác nhận thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
