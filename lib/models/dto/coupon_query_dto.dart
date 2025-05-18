import 'package:flutter_ecommerce/models/dto/pagination_query.dart';

class CouponQuery {
  final PaginationQuery? pagination;
  final String? code;
  final int? discountAmount;
  final bool? isActive;
  final String? sort;

  CouponQuery({
    this.pagination,
    this.code,
    this.discountAmount,
    this.isActive,
    this.sort,
  });

  Map<String, dynamic> toQueryMap() {
    final map = <String, dynamic>{};

    if (code != null && code!.isNotEmpty) map['code'] = code;
    if (discountAmount != null)
      map['discountAmount'] = discountAmount.toString();
    if (isActive != null) map['isActive'] = isActive.toString();
    if (sort != null && sort!.isNotEmpty) map['sort'] = sort;

    if (pagination != null) {
      map.addAll(pagination!.toQueryMap());
    }

    return map;
  }
}
