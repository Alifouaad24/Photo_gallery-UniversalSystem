import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/modules/gallery/views/photo_session.dart';
import 'package:photo_gallery/modules/gallery/views/session_photos_screen.dart';

class SessionFolderItem extends StatelessWidget {
  final PhotoSession session;

  const SessionFolderItem({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final hasImages = session.images.isNotEmpty;
    final coverImage = hasImages ? session.images.first : null;

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.SessionPhotosScreen, arguments: session);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
  }
}