class Coupon {
  final String id;
  final String code;
  final int discountAmount;
  final int usageCount;
  final int maxUsage;
  final DateTime createdAt;
  final List<String> appliedOrderIds;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.usageCount,
    required this.maxUsage,
    required this.createdAt,
    required this.appliedOrderIds,
    this.isActive = true,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      discountAmount: json['discountAmount'],
      usageCount: json['usageCount'] ?? 0,
      maxUsage: json['maxUsage'],
      createdAt: DateTime.parse(json['createdAt']),
      appliedOrderIds: List<String>.from(json['appliedOrderIds'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountAmount': discountAmount,
      'usageCount': usageCount,
      'maxUsage': maxUsage,
      'createdAt': createdAt.toIso8601String(),
      'appliedOrderIds': appliedOrderIds,
      'isActive': isActive,
    };
  }

  bool get isValid {
    return isActive && usageCount < maxUsage;
  }

  int get remainingUsage {
    return maxUsage - usageCount;
  }
}
