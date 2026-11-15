import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/models/splashResponseModel.dart';
import 'package:photo_gallery/modules/auth/controllers/AuthController.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
import 'package:photo_gallery/modules/home/controllers/home_controller.dart';
import 'package:photo_gallery/modules/splash/controllers/splash_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primary = Color(0xff4F46E5);
  static const _accent = Color(0xff7C3AED);
  static const _bg = Color(0xffF5F6FB);
  static const _textDark = Color(0xff1F2937);
  static const _border = Color(0xffEEF0F5);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: GetBuilder<HomeController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(controller),

                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _selectorsCard(),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                      children: [
                        // _menuCard(
                        //   icon: Icons.camera_alt_rounded,
                        //   color: Colors.blue,
                        //   title: "Camera",
                        //   onTap: () async {
                        //     var cameraController = Get.find<CameraGetController>();
                        //     cameraController.AddToItemAndInventory = false;
                        //     cameraController.ItemUpc = '';
                        //     cameraController.update();
                        //     final changed = await Get.toNamed(Routes.cameraSession);
                        //
                        //     if (changed == true) {
                        //       Get.toNamed(Routes.gallery);
                        //     }
                        //   },
                        // ),

                        // _menuCard(
                        //   icon: Icons.photo_library_rounded,
                        //   color: Colors.green,
                        //   title: "Gallery",
                        //   onTap: () {
                        //     Get.toNamed(Routes.gallery);
                        //   },
                        // ),
                        _menuCard(
                          icon: Icons.search,
                          color: const Color.fromARGB(255, 164, 175, 46),
                          title: "Inventory",
                          onTap: () {
                            Get.toNamed(Routes.showInventory);
                          },
                        ),
                        _menuCard(
                          icon: Icons.add,
                          color: Colors.orange,
                          title: "Inventory",
                          onTap: () {
                            Get.toNamed(Routes.addInventory);
                          },
                        ),
                        _menuCard(
                          icon: Icons.production_quantity_limits,
                          color: const Color.fromARGB(255, 161, 40, 139),
                          title: "Products",
                          onTap: () {
                            final StorageLocalService _storageService =
                                Get.find<StorageLocalService>();
                            var businessId = _storageService.readInt('business_id');
                            Get.toNamed(
                              Routes.showItems,
                              arguments: {'businessId': businessId},
                            );
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────── Header ─────────────────────────
  Widget _header(HomeController controller) {
    final name = controller.userName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(.5), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: name.isNotEmpty
                        ? Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(Icons.person, color: _primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back 👋",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.75),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _glassIconButton(
                  icon: Icons.logout_rounded,
                  onTap: () => Get.find<AuthController>().logout(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Release : ${HomeController.releaseDate}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // ───────────────────── Group & Business ─────────────────────
  Widget _selectorsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _selectorTile(
            icon: Icons.workspaces_rounded,
            label: "Group",
            color: _accent,
            child: GetBuilder<SplashController>(
              builder: (controller) {
                final groups = controller.Response;

                final selectedId = groups.any(
                  (g) => g['businessGroupId'] == controller.selectedGroupId,
                )
                    ? controller.selectedGroupId
                    : null;

                return DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: selectedId,
                    isExpanded: true,
                    isDense: true,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.white,
                    style: _dropdownTextStyle,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                    onChanged: (id) => controller.selectGroup(id),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('No Group'),
                      ),
                      ...groups.map(
                        (e) => DropdownMenuItem<int?>(
                          value: e['businessGroupId'] as int,
                          child: Text(
                            e['groupName']?.toString() ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, indent: 72, endIndent: 16, color: _border),
          _selectorTile(
            icon: Icons.storefront_rounded,
            label: "Business",
            color: _primary,
            child: GetBuilder<SplashController>(
              builder: (controller) {
                final businesses = controller.groupBusinesses;
                if (businesses.isEmpty) {
                  return const Text("No Business", style: _dropdownTextStyle);
                }

                final current = controller.selectedBusiness;
                final selected = businesses.contains(current)
                    ? current!
                    : businesses.first;

                return DropdownButtonHideUnderline(
                  child: DropdownButton<Business>(
                    value: selected,
                    isExpanded: true,
                    isDense: true,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.white,
                    style: _dropdownTextStyle,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                    onChanged: (business) {
                      if (business != null) {
                        controller.selectBusiness(business);
                      }
                    },
                    items: businesses
                        .map(
                          (e) => DropdownMenuItem<Business>(
                            value: e,
                            child: Text(
                              e.businessName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _dropdownTextStyle = TextStyle(
    color: _textDark,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  Widget _selectorTile({
    required IconData icon,
    required String label,
    required Color color,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Menu Card ─────────────────────────
  Widget _menuCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(.20), color.withOpacity(.06)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xffF3F4F8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}