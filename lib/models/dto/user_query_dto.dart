import 'package:flutter_ecommerce/models/dto/pagination_query.dart';

class UserQuery {
  final PaginationQuery? pagination;
  final String? fullName;
  final String? email;
  final String? role;
  final bool? isGuest;
  final int? isActive;
  final String? sort;

  UserQuery({
    this.pagination,
    this.fullName,
    this.email,
    this.role,
    this.isGuest,
    this.isActive,
    this.sort,
  });

  Map<String, dynamic> toQueryMap() {
    final map = <String, dynamic>{};

    if (sort != null && sort!.isNotEmpty) map['sort'] = sort;
    if (fullName != null && fullName!.isNotEmpty) map['fullName'] = fullName;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (role != null && role!.isNotEmpty) map['role'] = role;
    if (isActive != null) map['isActive'] = isActive.toString();
    if (isGuest != null) map['isGuest'] = isGuest.toString();

    if (pagination != null) {
      map.addAll(pagination!.toQueryMap());
    }

    return map;
  }
}
