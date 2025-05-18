import 'package:flutter_ecommerce/models/comment.dart';

class CreateCommentResponseDto {
  final int statusCode;
  final String message;
  final Comment data;

  CreateCommentResponseDto({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory CreateCommentResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateCommentResponseDto(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: Comment.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
