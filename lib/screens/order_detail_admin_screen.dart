import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/order_api_service.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/models/dto/order_detail.dart';
import 'package:flutter_ecommerce/models/dto/update_order_dto.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:intl/intl.dart';

class OrderDetailAdminScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailAdminScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailAdminScreen> createState() => _OrderDetailAdminScreenState();
}

class _OrderDetailAdminScreenState extends State<OrderDetailAdminScreen> {
  final orderApiService = OrderApiService(ApiClient());
  bool _isLoading = true;
  Order? _order;
  List<OrderDetail> _orderDetails = [];
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderData = await orderApiService.getOrderInfo(widget.orderId);
      final orderDetails = await orderApiService.getOrderDetail(widget.orderId);

      setState(() {
        _order = orderData;
        _orderDetails = orderDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Đã có lỗi xảy ra khi tải dữ liệu đơn hàng');
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

  void _updateOrderStatus(int newStatus) async {
    try {
      _showLoadingDialog('Đang cập nhật trạng thái đơn hàng...');

      await orderApiService.update(
          widget.orderId, UpdateOrderDto(status: newStatus));

      Navigator.pop(context);
      _fetchOrderDetails();
      _showSuccessSnackBar('Cập nhật trạng thái đơn hàng thành công');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Lỗi khi cập nhật trạng thái đơn hàng: $e');
    }
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

  String _getOrderStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Đang chuẩn bị';
      case 3:
        return 'Đang giao hàng';
      case 4:
        return 'Đã giao hàng';
      case 5:
        return 'Hoàn thành';
      case 6:
        return 'Đang hoàn trả';
      case 7:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getOrderStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.indigo;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.teal;
      case 5:
        return Colors.green;
      case 6:
        return Colors.amber;
      case 7:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodText(int method) {
    switch (method) {
      case 0:
        return 'Tiền mặt';
      case 1:
        return 'Chuyển khoản';
      case 2:
        return 'Thẻ tín dụng';
      default:
        return 'Không xác định';
    }
  }

  void _showUpdateStatusDialog(BuildContext context, int currentStatus) {
    int selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Cập nhật trạng thái đơn hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn trạng thái mới cho đơn hàng:'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Chờ xác nhận'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Đã xác nhận'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Đang chuẩn bị'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('Đang giao hàng'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('Đã giao hàng'),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text('Hoàn thành'),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text('Đang hoàn trả'),
                    ),
                    DropdownMenuItem(
                      value: 7,
                      child: Text('Đã hủy'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedStatus != currentStatus) {
                  _updateOrderStatus(selectedStatus);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cập nhật'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng ${_order?.code ?? ''}'),
        actions: [
          if (_order != null && _order!.status != 7)
            TextButton.icon(
              icon: const Icon(Icons.edit_note, color: Colors.white),
              label: const Text(
                'Cập nhật trạng thái',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _showUpdateStatusDialog(context, _order!.status),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Không tìm thấy thông tin đơn hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order summary card
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đơn hàng #${_order!.code}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(_order!.createdAt)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _getOrderStatusColor(_order!.status)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getOrderStatusColor(
                                            _order!.status),
                                      ),
                                    ),
                                    child: Text(
                                      _getOrderStatusText(_order!.status),
                                      style: TextStyle(
                                        color: _getOrderStatusColor(
                                            _order!.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Tổng tiền',
                                      currencyFormatter
                                          .format(_order!.totalPrice),
                                      Icons.attach_money,
                                      colorScheme.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Số lượng sản phẩm',
                                      _order!.itemCount.toString(),
                                      Icons.shopping_bag,
                                      Colors.blue,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Phương thức thanh toán',
                                      _getPaymentMethodText(
                                          _order!.paymentMethod),
                                      Icons.payment,
                                      Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              if (_order!.paymentAt != null) ...[
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  'Thời gian thanh toán',
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_order!.paymentAt!),
                                  Icons.access_time,
                                  Colors.orange,
                                ),
                              ],
                              if (_order!.deliveredAt != null) ...[
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  'Thời gian giao hàng',
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_order!.deliveredAt!),
                                  Icons.local_shipping,
                                  Colors.teal,
                                ),
                              ],
                              if (_order!.cancelledAt != null) ...[
                                const SizedBox(height: 16),
                                _buildInfoItem(
                                  'Thời gian hủy',
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_order!.cancelledAt!),
                                  Icons.cancel,
                                  Colors.red,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Customer information
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
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thông tin khách hàng',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildCustomerInfoItem(
                                'Họ và tên',
                                _order!.shippingInfo.name,
                                Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _buildCustomerInfoItem(
                                'Email',
                                _order!.shippingInfo.email,
                                Icons.email_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildCustomerInfoItem(
                                'Số điện thoại',
                                _order!.shippingInfo.phoneNumber,
                                Icons.phone_outlined,
                              ),
                              const SizedBox(height: 12),
                              _buildCustomerInfoItem(
                                'Địa chỉ giao hàng',
                                _order!.shippingInfo.address,
                                Icons.location_on_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Order items
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
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Danh sách sản phẩm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_orderDetails.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Không có thông tin sản phẩm',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _orderDetails.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    final item = _orderDetails[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product image
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              item.sku.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),

// Product details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.sku.product.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'SKU: ${item.sku.sku}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  spacing: 8,
                                                  children: item.sku.attributes
                                                      .map((attr) {
                                                    return Chip(
                                                      label: Text(
                                                        '${attr.name}: ${attr.value}',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      backgroundColor:
                                                          Colors.grey.shade100,
                                                      padding: EdgeInsets.zero,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Price and quantity
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                currencyFormatter
                                                    .format(item.sellingPrice),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'x${item.quantity}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Thành tiền: ${currencyFormatter.format(item.sellingPrice * item.quantity)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),

                              // Order summary
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng tiền hàng:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    currencyFormatter
                                        .format(_calculateSubtotal()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí vận chuyển:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    currencyFormatter
                                        .format(_calculateShippingFee()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Giảm giá:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '- ${currencyFormatter.format(_calculateDiscount())}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(thickness: 1),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng thanh toán:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter
                                        .format(_order!.totalPrice),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Quay lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (_order!.status != 7)
                            ElevatedButton.icon(
                              onPressed: () => _showUpdateStatusDialog(
                                  context, _order!.status),
                              icon: const Icon(Icons.edit),
                              label: const Text('Cập nhật trạng thái'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCustomerInfoItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in _orderDetails) {
      subtotal += item.sellingPrice * item.quantity;
    }
    return subtotal;
  }

  double _calculateShippingFee() {
    // This is a placeholder. In a real app, you would calculate the shipping fee
    // based on your business logic or retrieve it from the order data
    return 30000;
  }

  double _calculateDiscount() {
    // This is a placeholder. In a real app, you would calculate the discount
    // based on your business logic or retrieve it from the order data
    double subtotal = _calculateSubtotal();
    double shippingFee = _calculateShippingFee();
    return (subtotal + shippingFee) - _order!.totalPrice;
  }
}
