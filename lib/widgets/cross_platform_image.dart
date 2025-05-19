import 'dart:io' show File; // Used for File (mobile)
import 'dart:typed_data'; // Used for Uint8List (web or image processing)

import 'package:flutter/foundation.dart'; // Used for kIsWeb
import 'package:flutter/material.dart'; // Used for Flutter widgets

// Cross-platform image widget that works on web, mobile, and handles network images
class CrossPlatformImage extends StatelessWidget {
  final dynamic imageSource; // Can be File, Uint8List, or String (URL)
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

    // Handle network URLs (String type)
    if (imageSource is String && imageSource.toString().startsWith('http')) {
      imageWidget = Image.network(
        imageSource,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else if (kIsWeb) {
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
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
