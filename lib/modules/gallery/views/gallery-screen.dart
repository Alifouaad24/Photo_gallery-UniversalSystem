import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/services/storage_service.dart';
import 'package:photo_gallery/modules/camera/views/camera-session.dart';
import 'package:photo_gallery/modules/gallery/views/photo_session.dart';
import 'package:photo_gallery/widgets/session_folder_item.dart';


class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<Map<DateTime, List<PhotoSession>>> future;

  @override
  void initState() {
    super.initState();
    future = StoragePhotoService.loadSessions();
  }

  void _reload() {
    setState(() {
      future = StoragePhotoService.loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          final result = await Get.toNamed(Routes.cameraSession);

          if (result == true) {
            _reload();
          }
        },
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final grouped = snapshot.data!;
          if (grouped.isEmpty) {
            return const Center(child: Text('No recent sessions'));
          }

          final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: days.length,
            itemBuilder: (_, i) {
              final day = days[i];
              final sessions = grouped[day]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${day.year}-${day.month}-${day.day}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sessions.length,
                      itemBuilder: (_, j) =>
                          SessionFolderItem(session: sessions[j]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
