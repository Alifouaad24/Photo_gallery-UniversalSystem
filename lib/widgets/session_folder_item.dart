import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_session.dart';
import '../screens/session_photos_screen.dart';

class SessionFolderItem extends StatelessWidget {
  final PhotoSession session;

  const SessionFolderItem({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final hasImages = session.images.isNotEmpty;
    final coverImage = hasImages ? session.images.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionPhotosScreen(session: session),
          ),
        );
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
            // صورة الغلاف
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

            // عدد الصور
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