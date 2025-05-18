import 'package:flutter_ecommerce/models/dto/date_range_query.dart';
import 'package:flutter_ecommerce/models/dto/pagination_query.dart';

class ProductQuery {
  final String? sort;
  final String? code;
  final String? name;
  final List<String>? categoryIds;
  final List<String>? brandIds;
  final String? status;
  final double? minPrice;
  final double? maxPrice;
  final int? hasDiscount;
  final PaginationQuery? pagination;
  final DateRangeQuery? dateRange;

  ProductQuery({
    this.sort,
    this.code,
    this.name,
    this.categoryIds,
    this.brandIds,
    this.hasDiscount,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.pagination,
    this.dateRange,
  });

  Map<String, dynamic> toQueryMap() {
    final map = <String, dynamic>{};

    if (sort != null && sort!.isNotEmpty) map['sort'] = sort;
    if (code != null && code!.isNotEmpty) map['code'] = code;
    if (name != null && name!.isNotEmpty) map['name'] = name;
    if (categoryIds != null && categoryIds!.isNotEmpty)
      map['categoryIds'] = categoryIds!.join(',');
    if (brandIds != null && brandIds!.isNotEmpty)
      map['brandIds'] = brandIds!.join(',');
    if (hasDiscount != null) map['hasDiscount'] = hasDiscount.toString();
    if (status != null && status!.isNotEmpty) map['status'] = status;
    if (minPrice != null) map['minPrice'] = minPrice.toString();
    if (maxPrice != null) map['maxPrice'] = maxPrice.toString();

    if (pagination != null) {
      map.addAll(pagination!.toQueryMap());
    }

    if (dateRange != null) {
      map.addAll(dateRange!.toQueryMap());
    }

    return map;
  }
}
