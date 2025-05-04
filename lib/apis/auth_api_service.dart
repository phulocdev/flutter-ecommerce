import 'package:flutter_ecommerce/models/dto/register_request_dto.dart';
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
      final response = await _apiClient.post('/auth/login', body: dto.toJson());
      return LoginResponseDto.fromJson(response);
    } on ApiException catch (e) {
      _handleApiError(e);
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }

  Future<LoginResponseDto> register(RegisterRequestDto dto) async {
    try {
      final response =
          await _apiClient.post('/auth/register', body: dto.toJson());
      return LoginResponseDto.fromJson(response);
    } on ApiException catch (e) {
      _handleApiError(e);
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }

  Future<void> logoutWithApi(String refreshToken) async {
    try {
      final response = await _apiClient.post('/auth/logout', body: {
        'refreshToken': refreshToken,
      });
      // Xử lý thành công khi logout
      print("Đăng xuất thành công: $response");
    } catch (e) {
      print("Lỗi khi gọi API logout: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenService.deleteTokens();
  }

  void _handleApiError(ApiException e) {
    if (e is AuthenticationException) {
      print("Lỗi xác thực: ${e.message}");
    } else if (e is BadRequestException) {
      print("Yêu cầu không hợp lệ: ${e.message}");
    } else {
      print("Lỗi API: ${e.message}");
    }
  }
}
