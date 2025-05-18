class CreateOrderRequestDto {
  final List<OrderItem> items;
  final String? userId;
  final int totalPrice;
  final int itemCount;
  final int? discountAmount;
  final int paymentMethod;
  final ShippingInfo shippingInfo;
  final String? couponCode; // Added coupon code field

  CreateOrderRequestDto({
    required this.items,
    this.userId,
    required this.totalPrice,
    required this.itemCount,
    this.discountAmount,
    required this.paymentMethod,
    required this.shippingInfo,
    this.couponCode, // Optional coupon code
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'userId': userId,
      'totalPrice': totalPrice,
      'itemCount': itemCount,
      'discountAmount': discountAmount,
      'paymentMethod': paymentMethod,
      'shippingInfo': shippingInfo.toJson(),
      'couponCode': couponCode, // Include coupon code in JSON
    };
  }
}

class OrderItem {
  final String sku;
  final int quantity;
  final String productId;
  final double costPrice;
  final double sellingPrice;

  OrderItem({
    required this.sku,
    required this.quantity,
    required this.productId,
    required this.costPrice,
    required this.sellingPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'quantity': quantity,
      'productId': productId,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
    };
  }
}

class ShippingInfo {
  final String name;
  final String email;
  final String phoneNumber;
  final String address;

  ShippingInfo({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}
