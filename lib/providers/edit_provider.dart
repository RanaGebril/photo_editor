import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProvider extends ChangeNotifier {
  File? croppedImage;
  Uint8List? currentImage;
  File? filteredImage;

  // Set the cropped image and notify listeners
  void setCroppedImage(File image) {
    croppedImage = image;
    notifyListeners();
  }

  Future<void> cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        //CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
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
      setCroppedImage(File(croppedFile.path)); // Set the cropped image result
    }
  }


  // Save Uint8List to a temporary file
  Future<File> saveUint8ListToFile(Uint8List data, String path) async {
    final file = File(path);
    await file.writeAsBytes(data);
    return file;
  }

  // Change the image and update currentImage, croppedImage, and filteredImage
  Future<void> changeImage(File image) async {
    currentImage = await image.readAsBytes(); // Convert image file to Uint8List
    croppedImage = image; // Update the cropped image for consistency

    // Save currentImage to a new file and update filteredImage
    final tempDir = Directory.systemTemp;
    final tempFilePath =
        '${tempDir.path}/filtered_image_${DateTime.now().millisecondsSinceEpoch}.png';
    filteredImage = await saveUint8ListToFile(currentImage!, tempFilePath);

    notifyListeners(); // Notify listeners after changing the image
  }
}
