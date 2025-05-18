class CreateCouponDto {
  final String code;
  final int discountAmount;
  final int maxUsage;

  CreateCouponDto({
    required this.code,
    required this.discountAmount,
    required this.maxUsage,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discountAmount': discountAmount,
      'maxUsage': maxUsage,
    };
  }
}
