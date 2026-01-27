import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/models/splashResponseModel.dart';
import 'package:photo_gallery/modules/auth/controllers/AuthController.dart';
import 'package:photo_gallery/modules/camera/views/camera-session.dart';
import 'package:photo_gallery/modules/gallery/views/gallery-screen.dart';
import 'package:photo_gallery/modules/home/controllers/home_controller.dart';
import 'package:photo_gallery/modules/splash/controllers/splash_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<SplashController>(
            builder: (controller) {
              final businesses = controller.userResponse?.businesses ?? [];
              if (businesses.isEmpty) {
                return const Text('No Business');
              }
              final selected = controller.selectedBusiness ?? businesses.first;
              return DropdownButtonHideUnderline(
                child: DropdownButton<Business>(
                  value: selected,
                  dropdownColor: Colors.black87,
                  icon: const SizedBox.shrink(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                  ),
                  onChanged: (business) {
                    if (business != null) {
                      controller.selectBusiness(business);
                    }
                  },
                  items: businesses.map((business) {
                    return DropdownMenuItem<Business>(
                      value: business,
                      child: Text(
                        business.businessName,
                        style: const TextStyle(color: Color.fromARGB(255, 240, 130, 130)),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        actions: [
          
        ],
        automaticallyImplyLeading: false,
      ),
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
