import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_editor/bottom_navigation_item.dart';
import 'package:photo_editor/filter/filter_screen.dart';
import 'package:photo_editor/providers/edit_provider.dart';
import 'package:provider/provider.dart';

import 'brightness/brightness_editor.dart';

class EditScreen extends StatefulWidget {
  static String routeName = 'edit';

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedImage = ModalRoute.of(context)?.settings.arguments as String?;

    if (selectedImage == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text('Error: No image provided'),
        ),
        body: const Center(child: Text('No image was passed for editing.')),
      );
    }

    return ChangeNotifierProvider(
      create: (context) {
        final editProvider = EditProvider();
        editProvider.initializeImage(File(selectedImage));
        return editProvider;
      },
      child: Consumer<EditProvider>(
        builder: (context, editProvider, child) {
          return Scaffold(
            backgroundColor: const Color(0xff0e0d0d),
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Implement save functionality here
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              width: double.infinity,
              height: 130,
              color: Colors.black,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    BottomNavigationItem(
                      onpressed: () async {
                        final tempFile = File('${Directory.systemTemp.path}/temp_image.png');
                        await tempFile.writeAsBytes(editProvider.currentImage!);
                        await editProvider.cropImage(tempFile);
                      },
                      title: 'Crop & Rotate',
                      Icons.crop_rotate,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        final tempFile = File('${Directory.systemTemp.path}/temp_image.png');
                        await tempFile.writeAsBytes(editProvider.currentImage!);
                        final filteredBytes = await Navigator.pushNamed(
                          context,
                          FilterScreen.routeName,
                          arguments: tempFile,
                        ) as Uint8List?;
                        if (filteredBytes != null) {
                          await editProvider.applyFilter(filteredBytes);
                        }
                      },
                      title: 'Filters',
                      Icons.filter_vintage_outlined,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        await editProvider.flipImage(horizontal: true); // Flip horizontally
                      },
                      title: 'Flip Horizontal',
                      Icons.flip,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        await editProvider.flipImage(horizontal: false); // Flip vertically
                      },
                      title: 'Flip Vertical',
                      Icons.flip_camera_android,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        final tempFile =
                            File('${Directory.systemTemp.path}/temp_image.png');
                        await tempFile.writeAsBytes(editProvider.currentImage!);
                        // Navigate to the BrightnessEditor
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BrightnessEditor(imagePath: tempFile.path),
                          ),
                        );
                      },
                      title: 'Brightness',
                      Icons.brightness_6,
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: editProvider.currentImage != null
                  ? Image.memory(
                editProvider.currentImage!,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                fit: BoxFit.contain,
              )
                  : const CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}