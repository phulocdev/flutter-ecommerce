import 'dart:typed_data';

import 'package:flutter_ecommerce/services/api_client.dart';

class ImageUploadApiServiceV2 {
  final apiClient = ApiClient();

  Future<void> uploadProfilePicture(Uint8List imageBytes) async {
    try {
      final imageUrl = await apiClient.uploadImage(
        imageBytes: imageBytes,
        folderName: 'profile-pictures',
        fileName: 'profile.jpg',
      );

      if (imageUrl != null) {
        print('Image uploaded successfully: $imageUrl');
      } else {
        print('Upload failed');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      if (e is AuthenticationException) {
        print(e);
      } else if (e is BadRequestException) {
        print(e);
      }
    }
  }
}
