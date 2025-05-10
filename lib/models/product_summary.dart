class ProductSummary {
  final String _id;
  final String code;
  final String name;
  final String description;
  final String imageUrl;
  final String? category;
  final String? brand;
  final String status;
  final double basePrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;

  const ProductSummary({
    required String id,
    required this.code,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.category,
    this.brand,
    required this.status,
    required this.basePrice,
    required this.createdAt,
    required this.updatedAt,
    required this.views,
  }) : _id = id;

  String get id => _id;

  factory ProductSummary.fromJson(Map<String, dynamic> json) => ProductSummary(
        id: json['_id'],
        code: json['code'],
        name: json['name'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        category: json['category'] is String
            ? json['category']
            : (json['category']?['_id'] ?? ''),
        brand: json['brand'] is String
            ? json['brand']
            : (json['brand']?['_id'] ?? ''),
        status: json['status'],
        basePrice: (json['basePrice'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        views: json['views'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'category': category,
        'brand': brand,
        'status': status,
        'basePrice': basePrice,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'views': views,
      };
}
