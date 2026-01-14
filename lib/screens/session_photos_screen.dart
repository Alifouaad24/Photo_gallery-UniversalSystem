import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_session.dart';

class SessionPhotosScreen extends StatelessWidget {
  final PhotoSession session;

  const SessionPhotosScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${session.createdAt.year}-${session.createdAt.month}-${session.createdAt.day}',
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: session.images.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (_, index) {
          final file = session.images[index];
          return Image.file(file, fit: BoxFit.cover);
        },
      ),
    );
  }
}
