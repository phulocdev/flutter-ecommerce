import 'dart:io' show File; // Dùng cho File (mobile)
import 'dart:typed_data'; // Dùng cho Uint8List (web hoặc xử lý ảnh)

import 'package:flutter/foundation.dart'; // Dùng cho kIsWeb
import 'package:flutter/material.dart'; // Dùng cho các widget Flutter

// Cross-platform image widget that works on both web and mobile
class CrossPlatformImage extends StatelessWidget {
  final dynamic imageSource; // Can be File or Uint8List
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CrossPlatformImage({
    Key? key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb) {
      // For web, use Image.memory with Uint8List
      if (imageSource is Uint8List) {
        imageWidget = Image.memory(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        // Fallback for web if not Uint8List
        imageWidget = Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }
    } else {
      // For mobile, use Image.file
      if (imageSource is File) {
        imageWidget = Image.file(
          imageSource,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        // Fallback for mobile if not File
        imageWidget = Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
