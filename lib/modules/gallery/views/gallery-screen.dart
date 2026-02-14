import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/models/folderModel.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
import 'package:photo_gallery/widgets/session_folder_item.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GetBuilder<GalleryController>(
        builder: (controller) {
          if (controller.Sessions.isEmpty) {
            return const Center(child: Text('No recent sessions'));
          }

          Map<String, List<Folder>> groupedByDate = {};
          for (var session in controller.Sessions) {
            final date = session.name.trim().split('|').first;

            if (!groupedByDate.containsKey(date)) {
              groupedByDate[date] = [];
            }

            if (!groupedByDate[date]!.any((e) => e.id == session.id)) {
              groupedByDate[date]!.add(session);
            }
          }

          final dates = groupedByDate.keys.toList();

          print('dates dates: ${dates.length}');
          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (_, i) {
              final date = dates[i];
              final sessionsOfDay = groupedByDate[date]!;
              for (var i in sessionsOfDay) {
                print(
                  'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii: ${i.name}',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 150,
                    child: SessionFolderList(sessions1: sessionsOfDay),
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
