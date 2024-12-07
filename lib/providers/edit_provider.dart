import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Import the image package
import 'package:image_cropper/image_cropper.dart';

class EditProvider with ChangeNotifier {
  Uint8List? currentImage;

  // Crop the image and update the state
  Future<void> cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio7x5,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Custom Crop Image',
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        toolbarColor: Colors.deepPurple,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: Colors.deepPurple,
        cropFrameColor: Colors.white,
        cropGridColor: Colors.white,
      ),
    );

    if (croppedFile != null) {
      currentImage = await croppedFile.readAsBytes();
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Initialize the image from a file
  Future<void> initializeImage(File imageFile) async {
    currentImage = await imageFile.readAsBytes();
    notifyListeners();
  }

  // Apply a filter and update the state
  Future<void> applyFilter(Uint8List filteredBytes) async {
    currentImage = filteredBytes;
    notifyListeners(); // Notify listeners to update the UI
  }

  // Flip the image and update the state
  Future<void> flipImage({bool horizontal = true}) async {
    if (currentImage == null) return;

    // Decode the current image to a mutable format
    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Perform the flip operation
    final flippedImage = horizontal
        ? img.flipHorizontal(originalImage)
        : img.flipVertical(originalImage);

    // Encode the flipped image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(flippedImage));
    notifyListeners(); // Notify listeners to update the UI
  }

  // Update the current image with filtered bytes
  void updateFilteredImage(Uint8List filteredBytes) {
    currentImage = filteredBytes;
    notifyListeners(); // Notify listeners to update the UI
  }

  // Adjust brightness of the image
  // Adjust brightness of the image
  Future<void> adjustBrightness(int adjustment) async {
    if (currentImage == null) return;

    // Decode the current image to a mutable format
    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Adjust brightness
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final pixel = originalImage.getPixel(x, y);
        final r = img.getRed(pixel) + adjustment;
        final g = img.getGreen(pixel) + adjustment;
        final b = img.getBlue(pixel) + adjustment;

        // Clamp values to be between 0 and 255
        final newPixel = img.getColor(
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
        originalImage.setPixel(x, y, newPixel);
      }
    }

    // Encode the adjusted image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(originalImage));
    notifyListeners(); // Notify listeners to update the UI
  }


  Future<void> applyBlur(double blurValue) async {
    if (currentImage == null || blurValue == 0.0) return;

    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Convert image to blur
    final blurredImage = img.gaussianBlur(originalImage, blurValue.toInt());

    // Encode the blurred image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(blurredImage));
    notifyListeners();
  }

  // Adjust sharpness of the image
  Future<void> adjustSharpness(double sharpnessFactor) async {
    if (currentImage == null || sharpnessFactor == 0.0) return;

    // Decode the current image to a mutable format
    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Define a simple sharpening kernel
    final sharpenKernel = [
      -1, -1, -1,
      -1,  9, -1,
      -1, -1, -1,
    ];

    // Apply the kernel to the image
    final sharpenedImage = img.convolution(originalImage, sharpenKernel);

    // Encode the sharpened image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(sharpenedImage));
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<void> adjustContrast(double contrastFactor) async {
    if (currentImage == null || contrastFactor == 1.0) return;

    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Apply contrast adjustment
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final pixel = originalImage.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        final avg = (r + g + b) / 3;

        final newR = ((r - avg) * contrastFactor + avg).clamp(0, 255).toInt();
        final newG = ((g - avg) * contrastFactor + avg).clamp(0, 255).toInt();
        final newB = ((b - avg) * contrastFactor + avg).clamp(0, 255).toInt();

        final newPixel = img.getColor(newR, newG, newB);
        originalImage.setPixel(x, y, newPixel);
      }
    }

    currentImage = Uint8List.fromList(img.encodePng(originalImage));
    notifyListeners();
  }


  Future<void> adjustSaturation(double saturationFactor) async {
    if (currentImage == null || saturationFactor == 1.0) return;

    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Adjust saturation using a basic formula
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final pixel = originalImage.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);

        // Convert to grayscale to adjust saturation
        final avg = (r + g + b) / 3;
        final newR = ((r - avg) * saturationFactor + avg).clamp(0, 255).toInt();
        final newG = ((g - avg) * saturationFactor + avg).clamp(0, 255).toInt();
        final newB = ((b - avg) * saturationFactor + avg).clamp(0, 255).toInt();

        final newPixel = img.getColor(newR, newG, newB);
        originalImage.setPixel(x, y, newPixel);
      }
    }

    currentImage = Uint8List.fromList(img.encodePng(originalImage));
    notifyListeners();
  }


}