class PaginationQuery {
  final int? page;
  final int? limit;

  PaginationQuery({this.page, this.limit});

  Map<String, dynamic> toQueryMap() {
    final map = <String, dynamic>{};
    if (page != null) map['page'] = page.toString();
    if (limit != null) map['limit'] = limit.toString();
    return map;
  }
}
