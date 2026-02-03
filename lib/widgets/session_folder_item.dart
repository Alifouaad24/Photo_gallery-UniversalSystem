import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/photo_session.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
import 'package:photo_gallery/modules/gallery/views/session_photos_screen.dart';

class SessionFolderList extends StatelessWidget {
  const SessionFolderList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryController>(
      builder: (controller) {
        final sessions = controller.groupedSessions.values.expand((e) => e).toList();
        return sessions.isEmpty
            ? const Center(child: Text('No sessions found'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: sessions.map((session) {
                    final hasImages = session.images.isNotEmpty;
                    final coverImage = hasImages ? session.images.first : null;

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Session'),
                            content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  controller.deleteSession(session);
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
                                'Folder deleted successfully',
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
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        });
                      },
                      onTap: () {
                        Get.to(() => const SessionPhotosScreen(),
                            arguments: session);
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
                              child: hasImages
                                  ? Image.file(
                                      coverImage!,
                                      fit: BoxFit.cover,
                                      key: ValueKey(
                                        coverImage.path +
                                            coverImage
                                                .lastModifiedSync()
                                                .toString(),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.folder,
                                        size: 50,
                                        color: Colors.white54,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${session.images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
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
