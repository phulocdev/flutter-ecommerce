import 'package:flutter_ecommerce/models/dto/login_response_dto.dart';

class Comment {
  final String _id;
  final String productId;
  final Account? account;
  final String content;
  final String name;
  final int? stars;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required String id,
    required this.productId,
    this.account,
    required this.content,
    required this.name,
    this.stars,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  }) : _id = id;

  String get id => _id;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] as String,
      productId: json['productId'] as String,
      account:
          json['accountId'] != null && json['accountId'] is Map<String, dynamic>
              ? Account.fromJson(json['accountId'] as Map<String, dynamic>)
              : null,
      content: json['content'] as String,
      name: json['name']?.toString() ?? '',
      stars: json['stars'] != null ? (json['stars'] as num).toInt() : null,
      email: json['email']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
