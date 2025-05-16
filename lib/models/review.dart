import 'package:flutter/material.dart';

class Review {
  final String id;
  final String? userId;
  final String? userName;
  final String productId;
  final String comment;
  final double rating;
  final DateTime createdAt;
  final bool isAnonymous;

  Review({
    required this.id,
    this.userId,
    this.userName,
    required this.productId,
    required this.comment,
    required this.rating,
    required this.createdAt,
    this.isAnonymous = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      productId: json['productId'] as String,
      comment: json['comment'] as String,
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }
}
