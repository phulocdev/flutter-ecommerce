import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final _storage = const FlutterSecureStorage();
  final _accessTokenKey = 'accessToken';
  final _refreshTokenKey = 'refreshToken';
  final _userKey = 'userData';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveUser({
    required String email,
    required String fullName,
    required String role,
  }) async {
    final userMap = {
      'email': email,
      'fullName': fullName,
      'role': role,
    };
    await _storage.write(key: _userKey, value: json.encode(userMap));
  }

  Future<Map<String, String>?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData == null) return null;
    return Map<String, String>.from(json.decode(userData));
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}
