class Category {
  final String _id;
  final String name;
  final String? parentCategory;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required String id,
    required this.name,
    this.parentCategory,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : _id = id;

  String get id => _id;

  factory Category.all() => Category(
        id: 'all',
        name: 'All',
        parentCategory: null,
        imageUrl: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['_id'] as String,
        name: json['name'] as String,
        parentCategory: json['parentCategory'] as String?,
        imageUrl: json['imageUrl'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.fromMillisecondsSinceEpoch(0),
      );

  Map<String, dynamic> toJson() => {
        '_id': _id,
        'name': name,
        'parentCategory': parentCategory,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
