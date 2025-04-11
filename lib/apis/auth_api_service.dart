import 'package:flutter_ecommerce/models/dto/login_request_dto.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient();
  final TokenService _tokenService = TokenService();

  Future<dynamic> login(LoginRequestDto dto) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        body: dto.toJson(),
      );

      if (response is Map<String, dynamic> &&
          response.containsKey('accessToken') &&
          response.containsKey('refreshToken')) {
        final String accessToken = response['accessToken'];
        final String refreshToken = response['refreshToken'];
        await _tokenService.saveTokens(accessToken, refreshToken);
      } else {
        print('Warning: Login response did not contain expected tokens.');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenService.deleteTokens();
  }
}
