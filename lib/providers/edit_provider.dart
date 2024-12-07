import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Import the image package
import 'package:image_cropper/image_cropper.dart';
import 'dart:math';  // Add this line to use Random


class EditProvider with ChangeNotifier {
  Uint8List? currentImage;
  Uint8List? originalImage; // Save the original image for cancellation

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

  Future<void> initializeImage(File imageFile) async {
    originalImage = await imageFile.readAsBytes(); // Save the original image
    currentImage = originalImage; // Set the current image to the original
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

  Future<void> addBorder(int borderSize, {int r = 0, int g = 0, int b = 0}) async {
    if (currentImage == null) return;

    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    // Create a new image with added border
    final borderedImage = img.Image(
      originalImage.width + 2 * borderSize,
      originalImage.height + 2 * borderSize,
    );

    // Fill the border area with the desired color
    img.fill(borderedImage, img.getColor(r, g, b));

    // Copy the original image onto the bordered image
    img.copyInto(
      borderedImage,
      originalImage,
      dstX: borderSize,
      dstY: borderSize,
    );

    // Encode the bordered image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(borderedImage));
    notifyListeners();
  }

  // Add noise to the image with different noise types
  Future<void> addNoise(String noiseType, double noiseLevel) async {
    if (currentImage == null || noiseLevel <= 0) return;

    // Decode the current image to a mutable format
    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    final random = Random();

    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        // Generate random number to determine if a pixel will be noisy
        if (random.nextDouble() < noiseLevel) {
          if (noiseType == 'salt_and_pepper') {
            // Salt and pepper noise: randomize between black or white
            final color = random.nextBool() ? 0 : 255;
            originalImage.setPixel(x, y, img.getColor(color, color, color));
          } else if (noiseType == 'salt') {
            // Salt noise: randomize white
            originalImage.setPixel(x, y, img.getColor(255, 255, 255));
          } else if (noiseType == 'pepper') {
            // Pepper noise: randomize black
            originalImage.setPixel(x, y, img.getColor(0, 0, 0));
          }
        }
      }
    }

    // Encode the noisy image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(originalImage));
    notifyListeners(); // Notify listeners to update the UI
  }


  Future<void> removeNoise(double threshold) async {
    if (currentImage == null || threshold <= 0) return;

    // Decode the current image to a mutable format
    final originalImage = img.decodeImage(currentImage!);
    if (originalImage == null) return;

    final width = originalImage.width;
    final height = originalImage.height;

    // Loop through each pixel to apply the noise removal
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        List<int> neighborColors = [];

        // Collect the color of surrounding pixels (3x3 window)
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final pixel = originalImage.getPixel(x + dx, y + dy);
            neighborColors.add(pixel);
          }
        }

        // Convert the list of pixels to RGB values
        List<int> rValues = [];
        List<int> gValues = [];
        List<int> bValues = [];

        for (var color in neighborColors) {
          rValues.add(img.getRed(color));
          gValues.add(img.getGreen(color));
          bValues.add(img.getBlue(color));
        }

        // Sort the RGB values to find the median
        rValues.sort();
        gValues.sort();
        bValues.sort();

        // Median RGB values
        int rMedian = rValues[4]; // The middle value in the sorted list
        int gMedian = gValues[4];
        int bMedian = bValues[4];

        // Get the original pixel value
        final originalPixel = originalImage.getPixel(x, y);
        final rOriginal = img.getRed(originalPixel);
        final gOriginal = img.getGreen(originalPixel);
        final bOriginal = img.getBlue(originalPixel);

        // Calculate the difference between the original pixel and the median
        int diffR = (rOriginal - rMedian).abs();
        int diffG = (gOriginal - gMedian).abs();
        int diffB = (bOriginal - bMedian).abs();

        // If the difference exceeds the threshold, replace the pixel with the median value
        if (diffR > threshold || diffG > threshold || diffB > threshold) {
          originalImage.setPixel(x, y, img.getColor(rMedian, gMedian, bMedian));
        }
      }
    }

    // Encode the cleaned image back to Uint8List
    currentImage = Uint8List.fromList(img.encodePng(originalImage));
    notifyListeners(); // Notify listeners to update the UI
  }

  // Cancel all changes and revert to the original image
  void cancel() {
    if (originalImage != null) {
      currentImage = originalImage; // Restore the original image
      notifyListeners(); // Notify listeners to update the UI
    }
  }
}
