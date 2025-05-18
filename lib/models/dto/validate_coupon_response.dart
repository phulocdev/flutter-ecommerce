class ValidateCouponResponse {
  final bool valid;
  final String? message;
  final CouponInfo? coupon;

  ValidateCouponResponse({
    required this.valid,
    this.message,
    this.coupon,
  });

  factory ValidateCouponResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCouponResponse(
      valid: json['valid'] ?? false,
      message: json['message'],
      coupon:
          json['coupon'] != null ? CouponInfo.fromJson(json['coupon']) : null,
    );
  }
}

class CouponInfo {
  final String id;
  final String code;
  final int discountAmount;
  final int remainingUsage;

  CouponInfo({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.remainingUsage,
  });

  factory CouponInfo.fromJson(Map<String, dynamic> json) {
    return CouponInfo(
      id: json['id'],
      code: json['code'],
      discountAmount: json['discountAmount'],
      remainingUsage: json['remainingUsage'],
    );
  }
}

class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      statusCode: json['statusCode'],
      message: json['message'],
      data: fromJsonT(json['data']),
    );
  }
}
