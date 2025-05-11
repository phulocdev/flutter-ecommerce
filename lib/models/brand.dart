class Brand {
  final String _id;
  final String name;
  final String? countryOfOrigin;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Brand({
    required String id,
    required this.name,
    this.countryOfOrigin,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : _id = id;

  String get id => _id;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['_id'] as String,
        name: json['name'] as String,
        countryOfOrigin: json['countryOfOrigin'] as String?,
        imageUrl: json['imageUrl'] as String,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'countryOfOrigin': countryOfOrigin,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
