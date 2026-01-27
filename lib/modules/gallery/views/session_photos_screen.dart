import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
import 'package:photo_gallery/models/photo_session.dart';
import 'package:photo_gallery/modules/gallery/views/fullScreenImg.dart';

class SessionPhotosScreen extends StatefulWidget {
  const SessionPhotosScreen({super.key});

  @override
  State<SessionPhotosScreen> createState() => _SessionPhotosScreenState();
}

class _SessionPhotosScreenState extends State<SessionPhotosScreen> {
  final controller = Get.find<GalleryController>();
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is PhotoSession) {
      controller.session = args;
    } else {
      Future.microtask(() => Get.back());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${controller.session.createdAt.year}-${controller.session.createdAt.month}-${controller.session.createdAt.day}',
          ),

          actions: [
            if (controller.selectedIndexes.isNotEmpty)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  final filesToUpload = controller.selectedIndexes
                      .map((i) => controller.session.images[i])
                      .toList();

                  switch (value) {
                    case 'upload':
                      controller.uploadImages(filesToUpload);
                      break;
                    case 'delete':
                      controller.deleteSelectedImages();
                      break;
                    case 'share':
                      //controller.shareImages(filesToUpload);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'upload',
                    child: Row(
                      children: [
                        Icon(Icons.cloud_upload, size: 20),
                        SizedBox(width: 8),
                        Text('Upload Images'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Images'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.session.images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (_, index) {
                final file = controller.session.images[index];
                final isSelected = controller.selectedIndexes.contains(index);

                return GestureDetector(
                  onLongPress: () {
                    controller.toggleSelection(index);
                  },
                  onTap: () async {
                    if (controller.selectedIndexes.isNotEmpty) {
                      controller.toggleSelection(index);
                      return;
                    }

                    final editedImage = await Get.to<File>(
                      () => FullScreenImageEditor(imageFile: file),
                    );

                    if (editedImage != null) {
                      controller.session.images[index] = editedImage;
                      controller.update();
                    }
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          key: ValueKey(file.path),
                        ),
                      ),

                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            color: Colors.green.withOpacity(0.35),
                          ),
                        ),

                      if (isSelected)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 26,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (controller.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
