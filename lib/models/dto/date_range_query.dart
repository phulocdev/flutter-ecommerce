class DateRangeQuery {
  final DateTime? from;
  final DateTime? to;

  DateRangeQuery({this.from, this.to});

  Map<String, dynamic> toQueryMap() {
    final map = <String, dynamic>{};
    if (from != null) map['from'] = from!.toIso8601String();
    if (to != null) map['to'] = to!.toIso8601String();
    return map;
  }
}
