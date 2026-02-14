import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/folderModel.dart';
import 'package:photo_gallery/models/photo_session.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
import 'package:photo_gallery/modules/gallery/views/session_photos_screen.dart';

class SessionFolderList extends StatelessWidget {
  final List<Folder> sessions1;
  const SessionFolderList({super.key, required this.sessions1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryController>(
      builder: (controller) {
        return sessions1.isEmpty
            ? const Center(child: Text('No sessions found'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: sessions1.map((session) {
                    print('session in SessionFolderList: ${session.id}');
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Session'),
                              content: const Text(
                                'Are you sure you want to delete this session? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Get.back();
                                    await controller.deleteSession(session.id!);
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
                                              color: const Color.fromARGB(
                                                221,
                                                86,
                                                85,
                                                85,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Folder deleted successfully',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    overlay.insert(entry);
                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        entry.remove();
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onTap: () {
                        controller.folderId = session.id;
                        controller.update();
                        Get.toNamed(Routes.SessionPhotosScreen);
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade900,
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: FutureBuilder<File?>(
                                future: controller.getCoverImage(session.id!),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data == null) {
                                    return const Center(
                                      child: Icon(
                                        Icons.folder,
                                        size: 50,
                                        color: Colors.white54,
                                      ),
                                    );
                                  }

                                  return Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FutureBuilder<int>(
                                  future: controller.getImgNumber(session.id!),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text(
                                        '0',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      );
                                    }

                                    return Text(
                                      snapshot.data.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
      },
    );
  }
}
