class CreateOrderRequestDto {
  final List<OrderItem> items;
  final String? userId;
  final int totalPrice;
  final int paymentMethod;
  final ShippingInfo shippingInfo;

  CreateOrderRequestDto(
      {required this.items,
      this.userId,
      required this.totalPrice,
      required this.paymentMethod,
      required this.shippingInfo});

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'userId': userId,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'shippingInfo': shippingInfo.toJson()
    };
  }
}

class OrderItem {
  final String sku;
  final int quantity;
  final double costPrice;
  final double sellingPrice;

  OrderItem({
    required this.sku,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'quantity': quantity,
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

  ShippingInfo(
      {required this.name,
      required this.email,
      required this.phoneNumber,
      required this.address});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address
    };
  }
}
