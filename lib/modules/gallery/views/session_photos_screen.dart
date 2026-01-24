import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
import 'package:photo_gallery/modules/gallery/views/photo_session.dart';
import 'package:photo_gallery/modules/gallery/views/fullScreenImg.dart';

class SessionPhotosScreen extends StatefulWidget {
  const SessionPhotosScreen({super.key});

  @override
  State<SessionPhotosScreen> createState() => _SessionPhotosScreenState();
}

class _SessionPhotosScreenState extends State<SessionPhotosScreen> {
  late final PhotoSession session;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is PhotoSession) {
      session = args;
    } else {
      Future.microtask(() => Get.back());
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = this.session;
    return GetBuilder<GalleryController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${session.createdAt.year}-${session.createdAt.month}-${session.createdAt.day}',
          ),
          actions: [
            if (controller.selectedIndexes.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.cloud_upload),
                onPressed: () {
                  final filesToUpload = controller.selectedIndexes
                      .map((i) => session.images[i])
                      .toList();
                   controller.uploadImages(filesToUpload);
                  //
                },
              ),
          ],
        ),
        body: Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: session.images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (_, index) {
              final file = session.images[index];
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
                    session.images[index] = editedImage;
                    controller.update();
                  }
                },
                child: Stack(
                  children: [
                    Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),
          
                    if (isSelected)
                      Positioned.fill(
                        child: Container(color: Colors.green.withOpacity(0.35)),
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
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ]
        ),
      ),
    );
  }
}
