import 'package:flutter_ecommerce/models/dto/create_user_dto.dart';
import 'package:flutter_ecommerce/models/dto/update_user_dto.dart';
import 'package:flutter_ecommerce/models/dto/user_query_dto.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class UserApiService {
  final ApiClient _apiClient;

  UserApiService(this._apiClient);

  Future<User> getUserById(String UserId) async {
    try {
      final response = await _apiClient.get('/accounts/$UserId');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final userData = response['data'];

        if (userData is Map<String, dynamic>) {
          return User.fromJson(userData);
        } else {
          throw Exception('Invalid API response: data should be map.');
        }
      } else if (response is List<dynamic>) {
        throw Exception(
            'Invalid API response: Expected a map but received a list.');
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching User with ID $UserId: $e');
      rethrow;
    }
  }

  Future<List<User>> getUsers({UserQuery? query}) async {
    try {
      final queryParams = query?.toQueryMap() ?? {};
      final uri = Uri(
        path: '/accounts',
        queryParameters: queryParams,
      );

      final response = await _apiClient.get(uri.toString());

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> userList = response['data'];

        if (userList is List<dynamic>) {
          return userList.map((userJson) => User.fromJson(userJson)).toList();
        } else {
          throw Exception('Invalid API response: data should be a list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching Users: $e');
      rethrow;
    }
  }

  Future create(CreateUserDto dto) async {
    try {
      final response = await _apiClient.post('/accounts', body: dto.toJson());
      return response;
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }

  Future update(String id, UpdateUserDto dto) async {
    try {
      final response =
          await _apiClient.patch('/accounts/$id', body: dto.toJson());
      return response;
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }
}
