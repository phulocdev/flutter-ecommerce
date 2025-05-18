import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // cần thiết cho kIsWeb
import 'package:flutter_ecommerce/utils/enum.dart';
import 'package:go_router/go_router.dart';

void navigateTo(
  BuildContext context,
  String path, {
  Object? extra,
  Map<String, String>? pathParameters,
}) {
  String finalPath = path;

  if (pathParameters != null) {
    pathParameters.forEach((key, value) {
      finalPath = finalPath.replaceAll(':$key', value);
    });
  }

  if (kIsWeb) {
    context.go(finalPath, extra: extra);
  } else {
    context.push(finalPath, extra: extra);
  }
}

OrderStatus parseOrderStatusFromInt(int? statusInt) {
  if (statusInt == null ||
      statusInt < 0 ||
      statusInt >= OrderStatus.values.length) {
    return OrderStatus.PROCESSING; // default fallback
  }
  return OrderStatus.values[statusInt];
}

String getOrderStatusText(OrderStatus status) {
  switch (status) {
    case OrderStatus.PROCESSING:
      return 'Đang xử lý';
    case OrderStatus.PENDING_PAYMENT:
      return 'Chờ thanh toán';
    case OrderStatus.COMPLETED:
      return 'Đã thanh toán';
    case OrderStatus.PACKED:
      return 'Đã đóng gói';
    case OrderStatus.SHIPPED:
      return 'Đang giao hàng';
    case OrderStatus.COMPLETED:
      return 'Hoàn tất';
    case OrderStatus.CANCELED:
      return 'Đã hủy';
    case OrderStatus.RETURNED:
      return 'Đã trả hàng';
    case OrderStatus.DELIVERED:
      return 'Đã giao hàng';
  }
}

Color getStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.PROCESSING:
      return Colors.orange;
    case OrderStatus.PENDING_PAYMENT:
      return Colors.yellow.shade700;
    case OrderStatus.COMPLETED:
      return Colors.lightGreen;
    case OrderStatus.PACKED:
      return Colors.teal;
    case OrderStatus.SHIPPED:
      return Colors.blue;
    case OrderStatus.COMPLETED:
      return Colors.green.shade700;
    case OrderStatus.CANCELED:
      return Colors.red;
    case OrderStatus.RETURNED:
      return Colors.purple;
    case OrderStatus.DELIVERED:
      return Colors.green;
  }
}

IconData getStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.PROCESSING:
      return Icons.pending;
    case OrderStatus.PENDING_PAYMENT:
      return Icons.access_time; // clock icon for waiting payment
    case OrderStatus.COMPLETED:
      return Icons.payment;
    case OrderStatus.PACKED:
      return Icons.inventory_2; // package icon
    case OrderStatus.SHIPPED:
      return Icons.local_shipping;
    case OrderStatus.COMPLETED:
      return Icons.check_circle_outline;
    case OrderStatus.CANCELED:
      return Icons.cancel;
    case OrderStatus.RETURNED:
      return Icons.undo; // return icon
    case OrderStatus.DELIVERED:
      return Icons.check_circle;
  }
}

Color getStatusBackgroundColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.PROCESSING:
      return Colors.orange;
    case OrderStatus.PENDING_PAYMENT:
      return Colors.yellow.shade700; // a warm yellow for pending payment
    case OrderStatus.COMPLETED:
      return Colors.lightGreen;
    case OrderStatus.PACKED:
      return Colors.teal;
    case OrderStatus.SHIPPED:
      return Colors.blue;
    case OrderStatus.COMPLETED:
      return Colors.green.shade700;
    case OrderStatus.CANCELED:
      return Colors.red;
    case OrderStatus.RETURNED:
      return Colors.purple;
    case OrderStatus.DELIVERED:
      return Colors.green;
    default:
      return Colors.grey;
  }
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}
