import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/edit_provider.dart';

class BrightnessEditor extends StatefulWidget {
  final String imagePath;

  const BrightnessEditor({Key? key, required this.imagePath}) : super(key: key);

  @override
  _BrightnessEditorState createState() => _BrightnessEditorState();
}

class _BrightnessEditorState extends State<BrightnessEditor> {
  double _brightness = 0.0; // قيمة السطوع تبدأ من 0
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final file = File(widget.imagePath);
    _imageBytes = await file.readAsBytes();
    setState(() {});
  }

  Future<void> _saveImage() async {
    Uint8List? bytes = await screenshotController.capture();
    if (bytes != null) {
      final result = await ImageGallerySaver.saveImage(bytes,
          name: 'edited_image.png'); // Ensure the name matches the original
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to gallery: $result')),
      );
      // Notify the provider to update the image
      Provider.of<EditProvider>(context, listen: false)
          .updateFilteredImage(bytes);
      Navigator.of(context).pop(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Brightness'),
        actions: [
          IconButton(
            onPressed: _saveImage,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Center(
        child: _imageBytes == null
            ? const CircularProgressIndicator()
            : Screenshot(
                controller: screenshotController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.white
                                .withOpacity(1 - ((_brightness + 1) / 2)),
                            BlendMode.modulate,
                          ),
                          child: Image.memory(
                            _imageBytes!,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
