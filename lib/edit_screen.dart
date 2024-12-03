import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_editor/bottom_navigation_item.dart';
import 'package:photo_editor/filter/filter_screen.dart';
import 'package:photo_editor/providers/edit_provider.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  static String routeName = 'edit';

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    // Retrieve the selected image path passed via the Navigator
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
                        final imageToCrop = editProvider.croppedImage ?? File(selectedImage);
                        await editProvider.cropImage(imageToCrop);
                      },
                      title: 'Crop & Rotate',
                      Icons.crop_rotate,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        final imageToFilter = editProvider.croppedImage ?? File(selectedImage);

                        // Navigate to FilterScreen and wait for the filtered image
                         Navigator.pushNamed(
                          context,
                          FilterScreen.routeName,
                          arguments: imageToFilter,
                        );
                      },
                      title: 'Filters',
                      Icons.filter_vintage_outlined,
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: Consumer<EditProvider>(
                builder: (context, editProvider, child) {
                  // Determine which image to display
                  final displayedImage = editProvider.filteredImage ??
                      editProvider.croppedImage ??
                      File(selectedImage);

                  return Container(
                    child: Image.file(
                      displayedImage,
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
