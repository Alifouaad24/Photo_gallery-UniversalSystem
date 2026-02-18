import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';

class FullScreenImageEditor extends StatefulWidget {
  final int initialIndex;

  const FullScreenImageEditor({super.key, required this.initialIndex});

  @override
  State<FullScreenImageEditor> createState() => _FullScreenImageEditorState();
}

class _FullScreenImageEditorState extends State<FullScreenImageEditor> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        body: GetBuilder<GalleryController>(
          builder: (controller) {
            return PageView.builder(
              controller: _pageController,
              itemCount: controller.currentImages.length,
              onPageChanged: (index) {
                currentIndex = index;
                controller.currentImage = File(
                  controller.currentImages[index].name,
                );
                controller.update();
              },
              itemBuilder: (context, index) {
                final file = File(controller.currentImages[index].name);

                return Center(
                  child: InteractiveViewer(child: Image.file(file)),
                );
              },
            );
          },
        ),
        bottomNavigationBar: _buildToolsBar(),
      ),
    );
  }

  Widget _buildToolsBar() {
    return GetBuilder<GalleryController>(
      builder: (controller) => BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.crop, color: Colors.white),
              onPressed: controller.cropImage,
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right, color: Colors.white),
              onPressed: controller.rotateImage,
            ),
            // IconButton(
            //   icon: const Icon(Icons.filter, color: Colors.white),
            //   onPressed: _applyGrayFilter,
            // ),
            // GetBuilder<GalleryController>(
            //   builder: (controller) => IconButton(
            //     icon: const Icon(Icons.qr_code, color: Colors.white),
            //     onPressed: () => controller.scanBarcodeFromImage(_currentImage),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
