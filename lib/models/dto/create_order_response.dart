class CreateOrderResponseDto {
  final int statusCode;
  final String message;
  final Order data;

  CreateOrderResponseDto({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory CreateOrderResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponseDto(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: Order.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class Order {
  final String id;
  final String user;
  final String code;
  final int status;
  final int totalPrice;
  final int itemCount;
  final int paymentMethod;
  final DateTime? paymentAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final ShippingInfo shippingInfo;
  final String? updateBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.user,
    required this.code,
    required this.status,
    required this.totalPrice,
    required this.paymentMethod,
    required this.itemCount,
    this.paymentAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.shippingInfo,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String,
      user: json['user'] as String,
      code: json['code'] as String,
      itemCount: json['itemCount'] as int,
      status: json['status'] as int,
      totalPrice: json['totalPrice'] as int,
      paymentMethod: json['paymentMethod'] as int,
      paymentAt:
          json['paymentAt'] != null ? DateTime.parse(json['paymentAt']) : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      shippingInfo: ShippingInfo.fromJson(json['shippingInfo']),
      updateBy: json['updateBy'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
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

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
    );
  }
}
