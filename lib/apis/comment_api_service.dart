import 'package:flutter_ecommerce/models/comment.dart';
import 'package:flutter_ecommerce/models/dto/create_comment_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_comment_response.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class CommentApiService {
  final ApiClient _apiClient;

  CommentApiService(this._apiClient);

  Future<List<Comment>> getComments(String productId) async {
    try {
      final response = await _apiClient.get('/comments/product/$productId');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> commentList = response['data'];

        if (commentList is List<dynamic>) {
          return commentList
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList();
        } else {
          throw Exception('Invalid API response: data should be a list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching Comments: $e');
      rethrow;
    }
  }

  Future<CreateCommentResponseDto> create(CreateCommentDto dto) async {
    try {
      final response = await _apiClient.post('/comments', body: dto.toJson());
      return CreateCommentResponseDto.fromJson(response);
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }
}
