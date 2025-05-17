// order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

// This would be your actual order detail model
class OrderDetail {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;
  final List<OrderStatus> statusHistory;
  final String shippingAddress;
  final String paymentMethod;
  final double shippingFee;

  OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
    required this.statusHistory,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.shippingFee,
  });
}

class OrderItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String variant;

  OrderItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.variant,
  });
}

class OrderStatus {
  final String status;
  final DateTime timestamp;
  final String? note;

  OrderStatus({
    required this.status,
    required this.timestamp,
    this.note,
  });
}

// This would be your actual provider
final orderDetailProvider =
    Provider.family<OrderDetail, String>((ref, orderId) {
  // Mock data for demonstration
  return OrderDetail(
    id: orderId,
    orderNumber: 'ORD-2023-00$orderId',
    orderDate: DateTime.now().subtract(const Duration(days: 2)),
    totalAmount: 1250000,
    status: 'Đang giao hàng',
    shippingAddress:
        '123 Đường Nguyễn Văn Linh, Phường Tân Phong, Quận 7, TP. Hồ Chí Minh',
    paymentMethod: 'Thanh toán khi nhận hàng (COD)',
    shippingFee: 30000,
    items: [
      OrderItem(
        id: '1',
        name: 'Áo thun nam cổ tròn basic',
        imageUrl: '/placeholder.svg',
        price: 250000,
        quantity: 2,
        variant: 'Màu trắng, Size L',
      ),
      OrderItem(
        id: '2',
        name: 'Quần jean nam slim fit',
        imageUrl: '/placeholder.svg',
        price: 750000,
        quantity: 1,
        variant: 'Màu xanh đậm, Size 32',
      ),
    ],
    statusHistory: [
      OrderStatus(
        status: 'Đang giao hàng',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        note: 'Đơn hàng đang được giao đến bạn',
      ),
      OrderStatus(
        status: 'Đã xác nhận',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        note: 'Đơn hàng đã được xác nhận',
      ),
      OrderStatus(
        status: 'Đang xử lý',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        note: 'Đơn hàng đang được xử lý',
      ),
      OrderStatus(
        status: 'Đã đặt hàng',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        note: 'Cảm ơn bạn đã đặt hàng',
      ),
    ],
  );
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderDetail = ref.watch(orderDetailProvider(orderId));
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(context, orderDetail),
            _buildOrderTimeline(context, orderDetail),
            _buildOrderItems(context, orderDetail),
            _buildOrderSummary(context, orderDetail),
            _buildShippingInfo(context, orderDetail),
            const SizedBox(height: 24),
            _buildActionButtons(context, orderDetail),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    // Determine status color
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'Đã giao hàng':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Đang giao hàng':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case 'Đang xử lý':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'Đã hủy':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

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
                order.orderNumber,
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
                      order.status,
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
            'Đặt hàng lúc: ${dateFormatter.format(order.orderDate)}',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

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
            itemCount: order.statusHistory.length,
            itemBuilder: (context, index) {
              final status = order.statusHistory[index];
              final isFirst = index == 0;
              final isLast = index == order.statusHistory.length - 1;

              // Determine status color
              Color statusColor;
              IconData statusIcon;

              switch (status.status) {
                case 'Đã giao hàng':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'Đang giao hàng':
                  statusColor = Colors.blue;
                  statusIcon = Icons.local_shipping;
                  break;
                case 'Đã xác nhận':
                  statusColor = Colors.blue;
                  statusIcon = Icons.thumb_up;
                  break;
                case 'Đang xử lý':
                  statusColor = Colors.orange;
                  statusIcon = Icons.pending;
                  break;
                case 'Đã đặt hàng':
                  statusColor = Colors.purple;
                  statusIcon = Icons.shopping_cart_checkout;
                  break;
                case 'Đã hủy':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.grey;
                  statusIcon = Icons.help_outline;
              }

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
                        status.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(status.timestamp),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      if (status.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          status.note!,
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

  Widget _buildOrderItems(BuildContext context, OrderDetail order) {
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
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceVariant,
                    ),
                    child: const Center(
                      child: Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.variant,
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
                              priceFormatter.format(item.price),
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

  Widget _buildOrderSummary(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priceFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    // Calculate subtotal
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

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
                priceFormatter.format(order.shippingFee),
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
                priceFormatter.format(order.totalAmount),
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
                        order.paymentMethod,
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

  Widget _buildShippingInfo(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            child: Row(
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
                    order.shippingAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderDetail order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            onPressed: () {
              // Implement buy again functionality
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Mua lại'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
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
}
