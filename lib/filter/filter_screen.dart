import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_editor/filter/filters.dart';
import 'package:photo_editor/model/filter.dart';
import 'package:photo_editor/providers/edit_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class FilterScreen extends StatefulWidget {
  static String routeName = 'filter';

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late Filter currentFilter;
  late List<Filter> filters;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    filters = Filters().list();
    currentFilter = filters[0];
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = ModalRoute.of(context)?.settings.arguments as File?;
    if (imageFile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filter')),
        body: const Center(child: Text('No image provided')),
      );
    }

    // Initialize the provider with the passed image
    final editProvider = Provider.of<EditProvider>(context, listen: false);
    editProvider.changeImage(imageFile);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Filter'),
        actions: [
          IconButton(
            onPressed: () async {
              Uint8List? bytes = await screenshotController.capture();

              if (bytes != null) {
                final directory = await getApplicationDocumentsDirectory();
                final filePath = '${directory.path}/filtered_image.png';
                final file = File(filePath);
                await file.writeAsBytes(bytes);

                editProvider.setFilteredImage(file);

                if (!mounted) return;
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Center(
        child: Consumer<EditProvider>(
          builder: (context, value, child) {
            final currentImage = value.currentImage;
            if (currentImage != null) {
              return Screenshot(
                controller: screenshotController,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(currentFilter.matrix),
                  child: Image.memory(currentImage),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 120,
        color: Colors.black,
        child: SafeArea(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              currentFilter = filter;
                            });
                          },
                          child: Consumer<EditProvider>(
                            builder: (context, value, child) {
                              final currentImage = value.currentImage;
                              if (currentImage != null) {
                                return ColorFiltered(
                                  colorFilter: ColorFilter.matrix(filter.matrix),
                                  child: Image.memory(
                                    currentImage,
                                    fit: BoxFit.fill,
                                    width: 60,
                                    height: 60,
                                  ),
                                );
                              }
                              return const SizedBox(); // Fallback if image is not ready
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      filter.filterName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
