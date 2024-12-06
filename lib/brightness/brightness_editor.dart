import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Image processing library

class BrightnessEditor extends StatefulWidget {
  final String imagePath;

  const BrightnessEditor({Key? key, required this.imagePath}) : super(key: key);

  @override
  _BrightnessEditorState createState() => _BrightnessEditorState();
}

class _BrightnessEditorState extends State<BrightnessEditor> {
  double _brightness = 0.0;
  Uint8List? _imageBytes;
  img.Image? _editableImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final file = File(widget.imagePath);
    _imageBytes = await file.readAsBytes();
    _editableImage = img.decodeImage(_imageBytes!);
    setState(() {});
  }

  void _applyBrightnessAdjustment() {
    if (_editableImage == null) return;

    // Create a copy of the original image to apply brightness adjustment
    final adjustedImage = img.Image.from(_editableImage!);

    for (int y = 0; y < adjustedImage.height; y++) {
      for (int x = 0; x < adjustedImage.width; x++) {
        final pixel = adjustedImage.getPixel(x, y);
        final r = (img.getRed(pixel) + (_brightness * 255)).clamp(0, 255);
        final g = (img.getGreen(pixel) + (_brightness * 255)).clamp(0, 255);
        final b = (img.getBlue(pixel) + (_brightness * 255)).clamp(0, 255);

        adjustedImage.setPixel(x, y, img.getColor(r.toInt(), g.toInt(), b.toInt()));
      }
    }

    // Encode the adjusted image back to Uint8List
    _imageBytes = Uint8List.fromList(img.encodePng(adjustedImage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Brightness'),
        actions: [
          IconButton(
            onPressed: () {
              _applyBrightnessAdjustment();
              Navigator.of(context).pop(_imageBytes); // Pass updated image bytes
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Center(
        child: _imageBytes == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: Image.memory(
                _imageBytes!,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Slider(
              value: _brightness,
              min: -1.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  _brightness = value;
                });
              },
            ),
            Text(
              'Brightness: ${(_brightness + 1).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
