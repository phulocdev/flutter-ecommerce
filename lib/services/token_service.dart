import 'dart:convert';
import 'package:flutter_ecommerce/models/dto/login_response_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final _storage = const FlutterSecureStorage();
  final _accessTokenKey = 'accessToken';
  final _refreshTokenKey = 'refreshToken';
  final _accountKey = 'accountData';

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

  Future<void> saveAccount(Account account) async {
    final accountMap = {
      '_id': account.id,
      'email': account.email,
      'fullName': account.fullName,
      'role': account.role,
      'avatarUrl': account.avatarUrl,
      'phoneNumber': account.phoneNumber,
      'address': account.address,
    };
    await _storage.write(key: _accountKey, value: json.encode(accountMap));
  }

  Future<Map<String, String>?> getAccount() async {
    final accountData = await _storage.read(key: _accountKey);
    if (accountData == null) return null;
    return Map<String, String>.from(json.decode(accountData));
  }

  Future<void> clearAccount() async {
    await _storage.delete(key: _accountKey);
  }
}
