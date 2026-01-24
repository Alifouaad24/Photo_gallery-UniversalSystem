import 'package:flutter/material.dart';
import 'package:photo_gallery/modules/camera/views/camera-session.dart';
import 'package:photo_gallery/modules/gallery/views/gallery-screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Sessions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open camera'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 55)),
              onPressed: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraSessionScreen(),
                  ),
                );

                if (changed == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 55)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GalleryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
