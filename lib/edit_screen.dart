import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_editor/providers/edit_provider.dart';
import 'package:provider/provider.dart';

import 'bottom_navigation_item.dart';
import 'brightness/brightness_editor.dart';
import 'filter/filter_screen.dart';

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
      create: (context) => EditProvider(),
      child: Consumer<EditProvider>(
        builder: (context, editProvider, child) {
          return Scaffold(
            backgroundColor: const Color(0xff0e0d),
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
                        final imageToCrop =
                            editProvider.croppedImage ?? File(selectedImage!);
                        await editProvider.cropImage(imageToCrop);
                      },
                      title: 'Crop & Rotate',
                      Icons.crop_rotate,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        final imageToFilter =
                            editProvider.croppedImage ?? File(selectedImage!);
                        Navigator.pushNamed(
                          context,
                          FilterScreen.routeName,
                          arguments: imageToFilter,
                        );
                      },
                      title: 'Filters',
                      Icons.filter_vintage_outlined,
                    ),
                    BottomNavigationItem(
                      Icons.brightness_6, // Brightness button
                      onpressed: () async {
                        final modifiedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BrightnessEditor(imagePath: selectedImage!),
                          ),
                        );
                        if (modifiedImage != null) {
                          editProvider.updateFilteredImage(modifiedImage);
                        }
                      },
                      title: 'Brightness',
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: Consumer<EditProvider>(
                builder: (context, editProvider, child) {
                  final displayedImage = editProvider.filteredImage ??
                      editProvider.croppedImage ??
                      File(selectedImage!);

                  return Container(
                    child: Image.file(
                      displayedImage,
                      key: ValueKey(displayedImage.path),
                      // Use the path as a key
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}