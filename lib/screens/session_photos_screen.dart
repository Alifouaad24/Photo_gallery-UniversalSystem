import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_gallery/screens/fullScreenImg.dart';
import '../models/photo_session.dart';

class SessionPhotosScreen extends StatefulWidget {
  final PhotoSession session;

  const SessionPhotosScreen({super.key, required this.session});

  @override
  State<SessionPhotosScreen> createState() => _SessionPhotosScreenState();
}

class _SessionPhotosScreenState extends State<SessionPhotosScreen> {
  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${session.createdAt.year}-${session.createdAt.month}-${session.createdAt.day}',
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: session.images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (_, index) {
          final file = session.images[index];

          return GestureDetector(
            onTap: () async {
              // ✅ فتح شاشة التحرير وانتظار النتيجة
              final editedImage = await Navigator.push<File>(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageEditor(imageFile: file),
                ),
              );

              // ✅ تحديث الصورة إذا تم الحفظ
              if (editedImage != null) {
                setState(() {
                  session.images[index] = editedImage;
                });
              }
            },
            child: Image.file(file, fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
