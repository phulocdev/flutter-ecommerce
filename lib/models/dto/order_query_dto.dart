import 'package:flutter_ecommerce/models/dto/date_range_query.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';

class OrderQuery {
  final String? sort;
  final String? code;
  final String? userId;
  final int? status;
  final String? paymentMethod;
  final double? minTotalPrice;
  final double? maxTotalPrice;
  final int? minItemCount;
  final int? maxItemCount;
  final DateTime? paymentFromDate;
  final DateTime? paymentToDate;
  final DateTime? deliveredFromDate;
  final DateTime? deliveredToDate;
  final PaginationQuery? pagination;
  final DateRangeQuery? dateRange;

  OrderQuery({
    this.sort,
    this.code,
    this.userId,
    this.status,
    this.paymentMethod,
    this.minTotalPrice,
    this.maxTotalPrice,
    this.minItemCount,
    this.maxItemCount,
    this.paymentFromDate,
    this.paymentToDate,
    this.deliveredFromDate,
    this.deliveredToDate,
    this.pagination,
    this.dateRange,
  });

  Map<String, dynamic> toQueryMap() {
    final map = <String, dynamic>{};

    if (sort != null && sort!.isNotEmpty) map['sort'] = sort;
    if (code != null && code!.isNotEmpty) map['code'] = code;
    if (userId != null && userId!.isNotEmpty) map['userId'] = userId;
    if (status != null) map['status'] = status;
    if (paymentMethod != null && paymentMethod!.isNotEmpty)
      map['paymentMethod'] = paymentMethod;
    if (minTotalPrice != null) map['minTotalPrice'] = minTotalPrice.toString();
    if (maxTotalPrice != null) map['maxTotalPrice'] = maxTotalPrice.toString();
    if (minItemCount != null) map['minItemCount'] = minItemCount.toString();
    if (maxItemCount != null) map['maxItemCount'] = maxItemCount.toString();

    if (paymentFromDate != null) {
      map['paymentFromDate'] = paymentFromDate!.toIso8601String();
    }
    if (paymentToDate != null) {
      map['paymentToDate'] = paymentToDate!.toIso8601String();
    }
    if (deliveredFromDate != null) {
      map['deliveredFromDate'] = deliveredFromDate!.toIso8601String();
    }
    if (deliveredToDate != null) {
      map['deliveredToDate'] = deliveredToDate!.toIso8601String();
    }

    if (pagination != null) {
      map.addAll(pagination!.toQueryMap());
    }

    if (dateRange != null) {
      map.addAll(dateRange!.toQueryMap());
    }

    return map;
  }
}
