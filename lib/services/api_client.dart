import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiClient {
  final TokenService _tokenService = TokenService();
  final String _baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://api.example.com'; // Fallback URL
  final String _refreshPath =
      dotenv.env['REFRESH_TOKEN_PATH'] ?? '/auth/refresh'; // Fallback path

  bool _isRefreshing = false;
  final List<Function> _requestQueue = []; // Queue requests during refresh

  // --- Private Helper for Sending Requests ---
  Future<http.Response> _sendRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    final headers = await _getHeaders(customHeaders);
    final encodedBody = body != null ? jsonEncode(body) : null;

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: encodedBody);
      case 'PUT':
        return await http.put(url, headers: headers, body: encodedBody);
      case 'DELETE':
        return await http.delete(url, headers: headers, body: encodedBody);
      case 'PATCH':
        return await http.patch(url, headers: headers, body: encodedBody);
      default:
        throw UnsupportedError('HTTP method $method not supported.');
    }
  }

  // --- Interceptor Logic ---
  Future<dynamic> _interceptedRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
  }) async {
    // Wait if a refresh is already in progress
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    http.Response response = await _sendRequest(
      method: method,
      path: path,
      body: body,
      customHeaders: customHeaders,
    );

    print('Response Status: ${response.statusCode} for $method $path');

    if (response.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final bool refreshed = await _refreshToken();
          _isRefreshing = false;

          if (refreshed) {
            print('Retrying request: $method $path');
            response = await _sendRequest(
              method: method,
              path: path,
              body: body,
              customHeaders: customHeaders,
            );
          } else {
            await _tokenService.deleteTokens();
            throw AuthenticationException(
                'Session expired. Please log in again.');
          }
        } catch (e) {
          _isRefreshing = false;
          await _tokenService.deleteTokens();
          throw AuthenticationException(
              'Session refresh failed: ${e.toString()}');
        }
      } else {
        while (_isRefreshing) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        response = await _sendRequest(
          method: method,
          path: path,
          body: body,
          customHeaders: customHeaders,
        );
        if (response.statusCode == 401) {
          await _tokenService.deleteTokens();
          throw AuthenticationException(
              'Authentication failed after token refresh.');
        }
      }
    }

    return _handleResponse(response);
  }

  // --- Response Handling &  ---
  dynamic _handleResponse(http.Response response) {
    final String responseBody = response.body;
    print('Response Body: $responseBody');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isNotEmpty) {
        try {
          return jsonDecode(responseBody);
        } catch (e) {
          throw FormatException(
              'Failed to decode JSON response: $e\nBody: $responseBody');
        }
      } else {
        return null;
      }
    } else {
      String errorMessage = 'API Error: ${response.statusCode}';
      if (responseBody.isNotEmpty) {
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map && decoded.containsKey('message')) {
            errorMessage = decoded['message'];
          } else {
            errorMessage = responseBody;
          }
        } catch (_) {
          errorMessage = responseBody;
        }
      }
      switch (response.statusCode) {
        case 400:
          throw BadRequestException(errorMessage);
        case 401:
          throw AuthenticationException('Unauthorized: $errorMessage');
        case 403:
          throw ForbiddenException(errorMessage);
        case 404:
          throw NotFoundException(errorMessage);
        case 500:
        default:
          throw ApiException('API Error ${response.statusCode}: $errorMessage');
      }
    }
  }

  // --- Token Refresh Logic ---
  Future<bool> _refreshToken() async {
    print('Attempting to refresh token...');
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) {
      print('No refresh token found.');
      return false; // Cannot refresh without a refresh token
    }

    try {
      final url = Uri.parse('$_baseUrl$_refreshPath');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        }, // Adjust headers as needed
        body:
            jsonEncode({'refreshToken': refreshToken}), // Adjust body as needed
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Adjust keys based on your backend's refresh response structure
        final newAccessToken = decoded['accessToken'] as String?;
        final newRefreshToken = decoded['refreshToken']
            as String?; // Optional: backend might issue a new refresh token

        if (newAccessToken != null) {
          await _tokenService.saveTokens(
              newAccessToken, newRefreshToken ?? refreshToken);
          print('Token refreshed successfully.');
          return true;
        } else {
          print('Refresh response did not contain new access token.');
          return false;
        }
      } else {
        print('Token refresh failed with status: ${response.statusCode}');
        print('Refresh Response Body: ${response.body}');
        return false; // Refresh failed
      }
    } catch (e) {
      print('Error during token refresh: $e');
      return false;
    }
  }

  // --- Helper to build headers ---
  Future<Map<String, String>> _getHeaders(
      Map<String, String>? customHeaders) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.acceptHeader: 'application/json',
    };
    final accessToken = await _tokenService.getAccessToken();
    if (accessToken != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    return await _interceptedRequest(
        method: 'GET', path: path, customHeaders: headers);
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return await _interceptedRequest(
        method: 'POST', path: path, body: body, customHeaders: headers);
  }

  Future<dynamic> put(String path,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return await _interceptedRequest(
        method: 'PUT', path: path, body: body, customHeaders: headers);
  }

  Future<dynamic> delete(String path,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return await _interceptedRequest(
        method: 'DELETE', path: path, body: body, customHeaders: headers);
  }

  Future<dynamic> patch(String path,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return await _interceptedRequest(
        method: 'PATCH', path: path, body: body, customHeaders: headers);
  }
}

// --- Custom Exception Classes ---
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class AuthenticationException extends ApiException {
  AuthenticationException(String message) : super(message);
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}
