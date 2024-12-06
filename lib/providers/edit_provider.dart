import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Import the image package
import 'package:image_cropper/image_cropper.dart';

class EditProvider extends ChangeNotifier {
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
      notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }
}
