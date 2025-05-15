// import 'package:flutter_ecommerce/models/dto/pagination_query.dart';

// class UserQuery {
//   final PaginationQuery pagination;
//   final String? fullName;
//   final String? email;
//   final String? role;
//   final bool? isActive;
//   final String? sort;

//   UserQuery({
//     required this.pagination,
//     this.fullName,
//     this.email,
//     this.role,
//     this.isActive,
//     this.sort,
//   });

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['pagination'] = pagination.toJson();
//     if (fullName != null) data['fullName'] = fullName;
//     if (email != null) data['email'] = email;
//     if (role != null) data['role'] = role;
//     if (isActive != null) data['isActive'] = isActive;
//     if (sort != null) data['sort'] = sort;
//     return data;
//   }
// }
