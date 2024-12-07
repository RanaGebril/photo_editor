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
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            int brightnessValue = 0; // Default brightness adjustment
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adjust Brightness',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      Slider(
                                        value: brightnessValue.toDouble(),
                                        min: -255,
                                        max: 255,
                                        divisions: 510,
                                        label: brightnessValue.toString(),
                                        onChanged: (value) {
                                          setModalState(() {
                                            brightnessValue = value.toInt();
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context); // Close the modal
                                          await editProvider.adjustBrightness(brightnessValue); // Apply brightness
                                        },
                                        child: Text('Apply Brightness'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      title: 'Brightness',
                      Icons.brightness_6,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            double blurValue = 0.0;
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adjust Blur',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      Slider(
                                        value: blurValue,
                                        min: 0,
                                        max: 20,
                                        divisions: 20,
                                        label: blurValue.toStringAsFixed(1),
                                        onChanged: (value) {
                                          setModalState(() {
                                            blurValue = value;
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context); // Close the modal
                                          await editProvider.applyBlur(blurValue); // Apply blur
                                        },
                                        child: Text('Apply Blur'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      title: 'Blur',
                      Icons.blur_on,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            double sharpnessValue = 1.0; // Default sharpness factor
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adjust Sharpness',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      Slider(
                                        value: sharpnessValue,
                                        min: 0.0,
                                        max: 3.0,
                                        divisions: 30,
                                        label: sharpnessValue.toStringAsFixed(1),
                                        onChanged: (value) {
                                          setModalState(() {
                                            sharpnessValue = value;
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context); // Close the modal
                                          await editProvider.adjustSharpness(sharpnessValue); // Apply sharpness
                                        },
                                        child: Text('Apply Sharpness'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      title: 'Sharpness',
                      Icons.shutter_speed,  // You can choose another icon for sharpness
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            double contrastValue = 1.0; // Default contrast factor
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adjust Contrast',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      Slider(
                                        value: contrastValue,
                                        min: 0.5,
                                        max: 3.0,
                                        divisions: 50,
                                        label: contrastValue.toStringAsFixed(1),
                                        onChanged: (value) {
                                          setModalState(() {
                                            contrastValue = value;
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await editProvider.adjustContrast(contrastValue);
                                        },
                                        child: Text('Apply Contrast'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      title: 'Contrast',
                      Icons.exposure,
                    ),
                    BottomNavigationItem(
                      onpressed: () async {
                        // Call the saturation adjustment function
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            double saturationValue = 1.0; // Default saturation adjustment
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Adjust Saturation',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      Slider(
                                        value: saturationValue,
                                        min: 0.0,
                                        max: 2.0,
                                        divisions: 20,
                                        label: saturationValue.toStringAsFixed(1),
                                        onChanged: (value) {
                                          setModalState(() {
                                            saturationValue = value;
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context); // Close the modal
                                          await editProvider.adjustSaturation(saturationValue); // Apply saturation
                                        },
                                        child: Text('Apply Saturation'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      title: 'Saturation',
                      Icons.color_lens, // You can use a suitable icon here
                    ),

                    BottomNavigationItem(
                      onpressed: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            int borderSize = 10;
                            int r = 0, g = 0, b = 0;

                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Add Border',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                      Row(
                                        children: [
                                          const Text('Border Size:', style: TextStyle(color: Colors.white)),
                                          Slider(
                                            value: borderSize.toDouble(),
                                            min: 0,
                                            max: 50,
                                            divisions: 10,
                                            label: borderSize.toString(),
                                            onChanged: (value) {
                                              setModalState(() {
                                                borderSize = value.toInt();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'Select Border Color',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Red: $r', style: const TextStyle(color: Colors.white)),
                                          Slider(
                                            value: r.toDouble(),
                                            min: 0,
                                            max: 255,
                                            divisions: 255,
                                            onChanged: (value) {
                                              setModalState(() {
                                                r = value.toInt();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Green: $g', style: const TextStyle(color: Colors.white)),
                                          Slider(
                                            value: g.toDouble(),
                                            min: 0,
                                            max: 255,
                                            divisions: 255,
                                            onChanged: (value) {
                                              setModalState(() {
                                                g = value.toInt();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Blue: $b', style: const TextStyle(color: Colors.white)),
                                          Slider(
                                            value: b.toDouble(),
                                            min: 0,
                                            max: 255,
                                            divisions: 255,
                                            onChanged: (value) {
                                              setModalState(() {
                                                b = value.toInt();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context); // Close the modal
                                          await editProvider.addBorder(borderSize, r: r, g: g, b: b); // Apply border
                                        },
                                        child: const Text('Apply Border'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      title: 'Add Border',
                      Icons.border_outer, // Replace with a suitable icon
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

