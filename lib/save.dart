import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Save {
  /// Save an image to the gallery
  static Future<void> saveImage(BuildContext context, Uint8List imageBytes) async {
    // Request permissions
    final status = await Permission.storage.request();

    if (status.isGranted) {
      // Save the image to the gallery
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100, // Image quality
        name: "edited_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      // Display result to the user
      if (result['isSuccess'] == true) {
        debugPrint('Image saved to gallery: ${result['filePath']}');
        _showSnackBar(context, "Image saved successfully!");
      } else {
        debugPrint('Failed to save image: $result');
        _showSnackBar(context, "Failed to save the image.");
      }
    } else {
      _showSnackBar(context, "Permission denied.");
    }
  }

  /// Show a snackbar with feedback
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
