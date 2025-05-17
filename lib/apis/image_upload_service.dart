import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  static final String baseUrl =
      'https://flutter-commerce-api.vercel.app/api/v1';
  static const String uploadEndpoint = '/media/upload/single';

  static Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String folderName,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$uploadEndpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'folder-name': folderName,
      });

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        final imageUrl = jsonResponse['result'];
        return imageUrl;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Helper to determine mime type from bytes (basic implementation)
  static String getMimeTypeFromBytes(Uint8List bytes) {
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

    // Default to octet-stream if cannot determine
    return 'application/octet-stream';
  }
}
