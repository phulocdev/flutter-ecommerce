import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';

import '../models/dto/login_request_dto.dart';
import '../models/dto/login_response_dto.dart';

class AuthApiService {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthApiService(this._apiClient, this._tokenService);
  
  
  Future<LoginResponseDto> login(LoginRequestDto dto) async {
    try {
      final response =
        await _apiClient.post('/auth/login', body: dto.toJson());

      return LoginResponseDto.fromJson(response);
    } catch (e) {
      if (e is Map<String, dynamic>) {
        print("Error: ${e['message']}");
      } else {
        print("Error: $e");
      }
      rethrow;
    }
  }
  Future<void> logout() async {
    await _tokenService.deleteTokens();
  }
}
