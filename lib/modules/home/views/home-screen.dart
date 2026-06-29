import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/splashResponseModel.dart';
import 'package:photo_gallery/modules/auth/controllers/AuthController.dart';
import 'package:photo_gallery/modules/home/controllers/home_controller.dart';
import 'package:photo_gallery/modules/splash/controllers/splash_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: GetBuilder<SplashController>(
          builder: (controller) {
            final businesses = controller.userResponse?.businesses ?? [];

            if (businesses.isEmpty) {
              return const Text("No Business");
            }

            final selected =
                controller.selectedBusiness ?? businesses.first;

            return DropdownButtonHideUnderline(
              child: DropdownButton<Business>(
                value: selected,
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (business) {
                  if (business != null) {
                    controller.selectBusiness(business);
                  }
                },
                items: businesses
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.businessName),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Get.find<AuthController>().logout();
            },
          )
        ],
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff3F51B5),
                        Color(0xff5C6BC0),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color(0xff3F51B5),
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        controller.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Release : ${HomeController.releaseDate}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: .95,
                  children: [

                    _menuCard(
                      icon: Icons.camera_alt_rounded,
                      color: Colors.blue,
                      title: "Camera",
                      onTap: () async {
                        final changed =
                            await Get.toNamed(Routes.cameraSession);

                        if (changed == true) {
                          Get.toNamed(Routes.gallery);
                        }
                      },
                    ),

                    _menuCard(
                      icon: Icons.photo_library_rounded,
                      color: Colors.green,
                      title: "Gallery",
                      onTap: () {
                        Get.toNamed(Routes.gallery);
                      },
                    ),

                    _menuCard(
                      icon: Icons.inventory_2_rounded,
                      color: Colors.orange,
                      title: "Inventory",
                      onTap: () {
                         Get.toNamed(Routes.showInventory);
                      },
                    ),

                    _menuCard(
                      icon: Icons.settings_rounded,
                      color: Colors.deepPurple,
                      title: "Settings",
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 33,
              backgroundColor: color.withOpacity(.12),
              child: Icon(
                icon,
                color: color,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}