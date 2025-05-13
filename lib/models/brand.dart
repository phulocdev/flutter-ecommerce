class Brand {
  final String _id;
  final String name;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Brand({
    required String id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : _id = id;

  String get id => _id;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['_id'] as String,
        name: json['name'] as String,
        imageUrl: json['imageUrl']?.toString() ?? '',
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
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
