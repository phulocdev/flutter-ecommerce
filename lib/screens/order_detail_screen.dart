// order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/order_api_service.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/models/dto/order_detail.dart';
import 'package:flutter_ecommerce/models/dto/update_order_dto.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/utils/enum.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<OrderDetail>? _orderDetail;
  bool _isLoading = true;

  final orderApiService = OrderApiService(ApiClient());

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderDetail = await orderApiService.getOrderDetail(widget.order.id);

      setState(() {
        _orderDetail = orderDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching order detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: colorScheme.primary),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orderDetail == null
              ? Center(
                  child: Text(
                    'Không tìm thấy thông tin đơn hàng',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.error,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderHeader(context),
                      _buildOrderTimeline(context),
                      _buildOrderItems(context, _orderDetail!),
                      _buildOrderSummary(context, _orderDetail!),
                      _buildShippingInfo(context),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    // Get order status
    final orderStatus = parseOrderStatusFromInt(widget.order.status);
    final statusColor = getStatusColor(orderStatus);
    final statusIcon = getStatusIcon(orderStatus);
    final statusText = getOrderStatusText(orderStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.order.code,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Đặt hàng lúc: ${dateFormatter.format(widget.order.createdAt)}',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    // Create status history from order data
    final statusHistory = <Map<String, dynamic>>[];

    // Current status
    final currentStatus = parseOrderStatusFromInt(widget.order.status);
    statusHistory.add({
      'status': currentStatus,
      'timestamp': widget.order.updatedAt,
      'note': 'Trạng thái hiện tại của đơn hàng',
    });

    // Add other statuses if they exist
    if (widget.order.cancelledAt != null) {
      statusHistory.add({
        'status': OrderStatus.CANCELED,
        'timestamp': widget.order.cancelledAt!,
        'note': 'Đơn hàng đã bị hủy',
      });
    }

    if (widget.order.deliveredAt != null) {
      statusHistory.add({
        'status': OrderStatus.DELIVERED,
        'timestamp': widget.order.deliveredAt!,
        'note': 'Đơn hàng đã được giao thành công',
      });
    }

    if (widget.order.paymentAt != null) {
      statusHistory.add({
        'status': OrderStatus.PAID,
        'timestamp': widget.order.paymentAt!,
        'note': 'Đơn hàng đã được thanh toán',
      });
    }

    // Sort by timestamp descending
    statusHistory.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statusHistory.length,
            itemBuilder: (context, index) {
              final status = statusHistory[index];
              final isFirst = index == 0;
              final isLast = index == statusHistory.length - 1;

              final orderStatus = status['status'] as OrderStatus;
              final statusColor = getStatusColor(orderStatus);
              final statusIcon = getStatusIcon(orderStatus);
              final statusText = getOrderStatusText(orderStatus);

              return TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: isFirst,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 30,
                  height: 30,
                  indicator: Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
                afterLineStyle: LineStyle(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
                endChild: Container(
                  constraints: const BoxConstraints(
                    minHeight: 80,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(status['timestamp']),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      if (status['note'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          status['note'],
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(
      BuildContext context, List<OrderDetail> orderDetails) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priceFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm đã mua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderDetails.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = orderDetails[index];

              // Format variant text from attributes
              final variantText = item.sku.attributes
                  .map((attr) => '${attr.name}: ${attr.value}')
                  .join(', ');

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceVariant,
                      image: DecorationImage(
                        image: NetworkImage(item.sku.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.sku.product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variantText,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              priceFormatter.format(item.sellingPrice),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, List<OrderDetail> order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priceFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    // Calculate subtotal
    final subtotal = widget.order.totalPrice;

    // Calculate shipping fee (assuming it's the difference between total and subtotal)
    // final shippingFee = order.totalPrice - subtotal;
    final shippingFee = 26000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính:',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                priceFormatter.format(subtotal),
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển:',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                priceFormatter.format(shippingFee),
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                priceFormatter.format(widget.order.totalPrice + 26000),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phương thức thanh toán',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getPaymentMethodText(widget.order.paymentMethod),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Format shipping address
    final shippingInfo = widget.order.shippingInfo;
    final formattedAddress = '${shippingInfo.address}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Địa chỉ giao hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${shippingInfo.name} | ${shippingInfo.phoneNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formattedAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Only show buy again button if order is delivered or cancelled
    final showBuyAgain = widget.order.status == OrderStatus.DELIVERED.index ||
        widget.order.status == OrderStatus.CANCELED.index;

    // Only show cancel button if order is pending or processing
    final showCancel = widget.order.status == OrderStatus.PROCESSING.index ||
        widget.order.status == OrderStatus.PROCESSING.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBuyAgain)
            FilledButton.icon(
              onPressed: () {
                navigateTo(context, AppRoute.productCatalog.path);
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Tiếp tục mua hàng'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          if (showBuyAgain && showCancel) const SizedBox(height: 12),
          if (showCancel)
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  final a = OrderStatus.CANCELED.index;
                  await orderApiService.update(widget.order.id,
                      UpdateOrderDto(status: OrderStatus.CANCELED.index));
                  showSuccessSnackBar(context, 'Hủy đơn hàng thành công');
                  navigateTo(context, AppRoute.historyOrders.path);
                } on ApiException catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    if (e.statusCode == 422 &&
                        e.errors != null &&
                        e.errors!.isNotEmpty) {
                      final errorMessages =
                          e.errors!.map((err) => err['message']).join(', ');
                      showErrorSnackBar(context, errorMessages);
                    } else {
                      showErrorSnackBar(context, 'Hủy đơn hàng: ${e.message}');
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Đã xảy ra lỗi không xác định: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Hủy đơn hàng'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // Implement contact support functionality
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('Liên hệ hỗ trợ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get payment method text
  String getPaymentMethodText(int paymentMethod) {
    switch (paymentMethod) {
      case 0:
        return 'Thanh toán khi nhận hàng (COD)';
      case 1:
        return 'Thanh toán qua thẻ tín dụng/ghi nợ';
      case 2:
        return 'Thanh toán qua ví điện tử';
      case 3:
        return 'Chuyển khoản ngân hàng';
      default:
        return 'Phương thức thanh toán khác';
    }
  }
}
