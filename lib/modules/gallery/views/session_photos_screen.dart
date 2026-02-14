import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/models/folderModel.dart';
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
    init();
  }

  Future<void> init() async {
    await controller.setFolder();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${controller.currentFolderName?.split('|').first ?? 'No Folder'} - ${controller.currentFolderName?.split('|').last ?? ''}',
          ),

          actions: [
            if (controller.selectedIndexes.isNotEmpty)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value)  {
                    case 'upload':
                      //controller.uploadImages(controller.sesion!);
                      break;
                    case 'delete':
                      await controller.deleteSelectedImages();

                      final context = Get.overlayContext;
                      if (context == null) return;

                      final overlay = Overlay.of(context);
                      if (overlay == null) return;

                      final entry = OverlayEntry(
                        builder: (_) => Positioned(
                          bottom: 100,
                          left: 20,
                          right: 20,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(221, 86, 85, 85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Images deleted successfully',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );

                      overlay.insert(entry);

                      Future.delayed(const Duration(seconds: 3), () {
                        entry.remove();
                      });

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
              itemCount: controller.currentImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (_, index) {
                final file = File(controller.currentImages[index].name);
                final isSelected = controller.selectedIndexes.contains(controller.currentImages[index]);
                final currentRec = controller.currentImages[index];
                return GestureDetector(
                  onLongPress: () {
                    controller.toggleSelection(controller.currentImages[index]);
                  },
                  onTap: () async {
                    if (controller.selectedIndexes.isNotEmpty) {
                      controller.toggleSelection(controller.currentImages[index]);
                      return;
                    }

                    controller.currentImage = file;

                    await Get.to<File>(
                      () => FullScreenImageEditor(
                        imageFile: controller.currentImage,
                      ),
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

                      if (currentRec.isUploaded)
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
