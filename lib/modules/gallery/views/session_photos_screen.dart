import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/folderModel.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
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
    controller.setFolder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<GalleryController>(
          builder: (controller) {
            final folderName = controller.currentFolderName;

            if (folderName == null || folderName.isEmpty) {
              return const Text('No Folder');
            }

            if (!folderName.contains('|')) {
              return Text(folderName);
            }

            final parts = folderName.split('|');
            final first = parts.isNotEmpty ? parts.first : '';
            final last = parts.length > 1 ? parts.last : '';

            return Text('$first - $last');
          },
        ),
        actions: [
          GetBuilder<GalleryController>(
            builder: (controller) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'camera':
                      {
                        final cameraController =
                            Get.find<CameraGetController>();
                        cameraController.currentFolderId = controller.folderId;
                        cameraController.update();
                        Get.toNamed(Routes.cameraSession);
                        break;
                      }
                    case 'upload':
                      // هنا ترفع الصور مباشرة
                      break;
                    case 'delete':
                      if (controller.selectedIndexes.isNotEmpty) {
                        await controller.deleteSelectedImages();
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'camera',
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, size: 20),
                        SizedBox(width: 8),
                        Text('Add more'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'upload',
                    enabled: controller.selectedIndexes.isNotEmpty,
                    child: Row(
                      children: [
                        Icon(Icons.cloud_upload, size: 20),
                        SizedBox(width: 8),
                        Text('Upload Images'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    enabled: controller.selectedIndexes.isNotEmpty,
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Images'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GetBuilder<GalleryController>(
            builder: (controller) {
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: controller.currentImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (_, index) {
                  final item = controller.currentImages[index];
                  final file = File(item.name);
                  final isSelected = controller.selectedIndexes.contains(item);

                  return GestureDetector(
                    onLongPress: () {
                      controller.toggleSelection(item);
                    },
                    onTap: () async {
                      if (controller.selectedIndexes.isNotEmpty) {
                        controller.toggleSelection(item);
                        return;
                      }

                      controller.currentImage = file;

                      await Get.to(
                        () => FullScreenImageEditor(initialIndex: index),
                      );
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              color: Colors.green.withOpacity(0.35),
                            ),
                          ),
                        if (item.isUploaded)
                          const Positioned(
                            bottom: 6,
                            right: 6,
                            child: Icon(
                              Icons.cloud_done_outlined,
                              color: Color.fromARGB(255, 19, 242, 130),
                              size: 26,
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
              );
            },
          ),
          GetBuilder<GalleryController>(
            builder: (controller) {
              if (!controller.isLoading) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
