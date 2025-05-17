import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'token_service.dart';

class ApiClient {
  final TokenService _tokenService = TokenService();
  final String _baseUrl = dotenv.env['BASE_URL']!;
  final String _refreshPath = dotenv.env['REFRESH_TOKEN_PATH']!;
  // final String _baseUrl = 'https://flutter-commerce-api.vercel.app/api/v1';
  // final String _refreshPath = '/auth/refresh-token';
  final String _uploadPath = '/media/upload/single';

  bool _isRefreshing = false;
  final List<Function> _requestQueue = [];

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
        throw UnsupportedError('Phương thức HTTP $method không được hỗ trợ.');
    }
  }

  Future<dynamic> _interceptedRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
  }) async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    http.Response response = await _sendRequest(
      method: method,
      path: path,
      body: body,
      customHeaders: customHeaders,
    );

    // print('Mã trạng thái phản hồi: ${response.statusCode} cho $method $path');

    if (response.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final bool refreshed = await _refreshToken();
          _isRefreshing = false;

          if (refreshed) {
            // print('Thử lại request: $method $path');
            response = await _sendRequest(
              method: method,
              path: path,
              body: body,
              customHeaders: customHeaders,
            );
          } else {
            await _tokenService.deleteTokens();
            throw AuthenticationException(
                'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.');
          }
        } catch (e) {
          _isRefreshing = false;
          await _tokenService.deleteTokens();
          throw AuthenticationException(
              'Làm mới phiên làm việc không thành công: ${e.toString()}');
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
              'Xác thực không thành công sau khi làm mới token.');
        }
      }
    }

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final String responseBody = response.body;
    // print('Nội dung phản hồi: $responseBody');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isNotEmpty) {
        try {
          return jsonDecode(responseBody);
        } catch (e) {
          throw FormatException(
              'Không thể giải mã phản hồi JSON: $e\nNội dung: $responseBody');
        }
      } else {
        return null;
      }
    } else {
      String errorMessage = 'Lỗi API: ${response.statusCode}';
      List<Map<String, dynamic>>? errors;

      if (responseBody.isNotEmpty) {
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('message')) {
              errorMessage = decoded['message'];
            }
            if (decoded.containsKey('errors') && decoded['errors'] is List) {
              errors = (decoded['errors'] as List)
                  .whereType<Map<String, dynamic>>()
                  .toList();
            }
          } else {
            errorMessage = responseBody;
          }
        } catch (_) {
          errorMessage = responseBody;
        }
      }

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(errorMessage, errors: errors);
        case 401:
          throw AuthenticationException('Authentication error: $errorMessage',
              errors: errors);
        case 403:
          throw ForbiddenException(errorMessage, errors: errors);
        case 404:
          throw NotFoundException(errorMessage, errors: errors);
        case 422:
          throw UnprocessableEntityException(
              message: errorMessage, errors: errors);
        case 500:
        default:
          throw ApiException('Lỗi API ${response.statusCode}: $errorMessage',
              errors: errors);
      }
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) {
      print('Không tìm thấy refresh token.');
      return false;
    }

    try {
      final url = Uri.parse('$_baseUrl$_refreshPath');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final newAccessToken = decoded['accessToken'] as String?;
        final newRefreshToken = decoded['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _tokenService.saveTokens(
              newAccessToken, newRefreshToken ?? refreshToken);
          print('Làm mới token thành công.');
          return true;
        } else {
          print('Phản hồi làm mới không chứa token truy cập mới.');
          return false;
        }
      } else {
        print(
            'Làm mới token không thành công với mã trạng thái: ${response.statusCode}');
        print('Nội dung phản hồi: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi làm mới token: $e');
      return false;
    }
  }

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

  /// Image upload functionality

  /// Uploads an image to the server
  /// Returns the URL of the uploaded image or null if upload failed
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String folderName,
    required String fileName,
    String? mimeType,
  }) async {
    // Determine mime type if not provided
    final String contentType = mimeType ?? getMimeTypeFromBytes(imageBytes);

    try {
      final Uri uri = Uri.parse('$_baseUrl$_uploadPath');
      final Map<String, String> authHeaders = await _getHeaders({
        'folder-name': folderName,
      });

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add auth headers and other headers
      request.headers.addAll(authHeaders);

      // Create multipart file
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      );

      // Add file to request
      request.files.add(multipartFile);

      // Intercept for token refresh if needed
      http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await request.send();
      } catch (e) {
        throw ApiException('Error sending upload request: ${e.toString()}');
      }

      // Handle 401 with token refresh
      if (streamedResponse.statusCode == 401) {
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            final bool refreshed = await _refreshToken();
            _isRefreshing = false;

            if (refreshed) {
              // Retry the upload with new token
              final newAuthHeaders = await _getHeaders({
                'folder-name': folderName,
              });

              final newRequest = http.MultipartRequest('POST', uri);
              newRequest.headers.addAll(newAuthHeaders);

              final newMultipartFile = http.MultipartFile.fromBytes(
                'file',
                imageBytes,
                filename: fileName,
                contentType: MediaType.parse(contentType),
              );

              newRequest.files.add(newMultipartFile);
              streamedResponse = await newRequest.send();
            } else {
              await _tokenService.deleteTokens();
              throw AuthenticationException(
                  'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.');
            }
          } catch (e) {
            _isRefreshing = false;
            await _tokenService.deleteTokens();
            throw AuthenticationException(
                'Làm mới phiên làm việc không thành công: ${e.toString()}');
          }
        }
      }

      // Convert streamed response to a regular response for consistent error handling
      final responseBytes = await streamedResponse.stream.toBytes();
      final response = http.Response(
        utf8.decode(responseBytes),
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
      );

      // Use the existing response handler
      final result = _handleResponse(response);

      // Extract image URL from the response
      if (result != null &&
          result is Map<String, dynamic> &&
          result.containsKey('data')) {
        final data = result['data'];
        if (data is Map<String, dynamic> && data.containsKey('result')) {
          return data['result'] as String?;
        }
      }

      return null;
    } catch (e) {
      print('Error uploading image: $e');
      if (e is ApiException) {
        // Re-throw API exceptions
        rethrow;
      }
      throw ApiException('Error uploading image: ${e.toString()}');
    }
  }

  /// Helper to determine mime type from bytes (basic implementation)
  String getMimeTypeFromBytes(Uint8List bytes) {
    // Check for JPEG signature
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // Check for PNG signature
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }

    // Check for GIF signature - 'GIF87a' or 'GIF89a'
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 && // G
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x38 && // 8
        (bytes[4] == 0x37 || bytes[4] == 0x39) && // 7 or 9
        bytes[5] == 0x61) {
      // a
      return 'image/gif';
    }

    // Check for WebP signature
    // WebP files start with RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46 && // F
        // Skip 4 bytes (file size)
        bytes[8] == 0x57 && // W
        bytes[9] == 0x45 && // E
        bytes[10] == 0x42 && // B
        bytes[11] == 0x50) {
      // P
      return 'image/webp';
    }

    // Default to octet-stream if cannot determine
    return 'application/octet-stream';
  }
}

// Các lớp ngoại lệ tùy chỉnh
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<Map<String, dynamic>>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class AuthenticationException extends ApiException {
  AuthenticationException(String message,
      {int? statusCode, List<Map<String, dynamic>>? errors})
      : super(message, statusCode: statusCode, errors: errors);
}

class UnprocessableEntityException extends ApiException {
  UnprocessableEntityException({
    String message = "Lỗi xác thực dữ liệu",
    List<Map<String, dynamic>>? errors,
  }) : super(message, statusCode: 422, errors: errors);
}

class BadRequestException extends ApiException {
  BadRequestException(String message,
      {int? statusCode, List<Map<String, dynamic>>? errors})
      : super(message, statusCode: statusCode, errors: errors);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message,
      {int? statusCode, List<Map<String, dynamic>>? errors})
      : super(message, statusCode: statusCode, errors: errors);
}

class NotFoundException extends ApiException {
  NotFoundException(String message,
      {int? statusCode, List<Map<String, dynamic>>? errors})
      : super(message, statusCode: statusCode, errors: errors);
}
