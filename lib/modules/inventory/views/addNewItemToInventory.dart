import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';

/// -------- Design tokens --------
class _Palette {
  static const bg = Color(0xFFF4F6F9);
  static const card = Colors.white;
  static const border = Color(0xFFEDEFF3);
  static const ink = Color(0xFF1B1F27);
  static const inkMuted = Color(0xFF6B7280);
  static const primary = Color(0xFF3457D5);
  static const primarySoft = Color(0xFFEFF2FF);
}

class Addnewitemtoinventory extends StatelessWidget {
  const Addnewitemtoinventory({super.key});

  Future<void> _openCamera() async {
    var cameraController = Get.find<CameraGetController>();
    cameraController.AddToItemAndInventory = true;
    cameraController.ItemUpc = '';
    cameraController.update();

    final changed = await Get.toNamed(Routes.cameraSession);

    if (changed == true) {
      Get.toNamed(Routes.gallery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      appBar: AppBar(
        backgroundColor: _Palette.card,
        elevation: 0,
        foregroundColor: _Palette.ink,
        title: const Text(
          "إضافة منتج جديد",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// -------- Illustration / icon circle --------
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _Palette.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 52,
                  color: _Palette.primary,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "أضف منتجًا جديدًا للمخزون",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _Palette.ink,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "صوّر المنتج بالكاميرا ليتم إضافته تلقائيًا إلى المخزون",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _Palette.inkMuted,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              /// -------- Camera button --------
              InkWell(
                onTap: _openCamera,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _Palette.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "فتح الكاميرا",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _Palette.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}