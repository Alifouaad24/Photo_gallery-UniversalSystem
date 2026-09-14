import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
import 'package:camera/camera.dart';
import 'package:photo_gallery/modules/camera/views/itemdataDialog.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';
import 'package:photo_gallery/modules/inventory/views/BarcodeScannerView.dart';

class CameraSessionScreen extends StatefulWidget {
  const CameraSessionScreen({super.key});

  @override
  State<CameraSessionScreen> createState() => _CameraSessionScreenState();
}

class _CameraSessionScreenState extends State<CameraSessionScreen> {
  final CameraGetController controller = Get.find<CameraGetController>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await controller.startCameraSession();
    await controller.initCamera();
    setState(() {});
  }

  void _showFlash() {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Container(color: Colors.white.withOpacity(0.7)),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 100), () {
      entry.remove();
    });
  }

  void _openItemDetailsDialog() {
    final cameraController = Get.find<CameraGetController>();
    

    showAddItemDetailsDialog(
      categories: cameraController.categories,
      platforms: controller.platforms,
      conditions: cameraController.conditions,
      initialValue: controller.newItemDetails,
      onSave: (result) {
        controller.newItemDetails = result;
        controller.update();
      },
    );
  }

  @override
  void dispose() {
    controller.endCameraSession();
    controller.currentFolderId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraGetController>(
      builder: (_) {
        if (!controller.cameraReady || controller.camera == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasItemDetails = controller.newItemDetails != null;
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(
                  key: ValueKey(controller.camera.hashCode),
                  controller.camera!,
                ),
              ),
              if (controller.AddToItemAndInventory)
                Positioned(
                  top: 90,
                  right: 20,
                  child: InkWell(
                    onTap: _openItemDetailsDialog,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: hasItemDetails
                            ? const Color(0xFF1CA97C)
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasItemDetails
                                ? Icons.check_circle_rounded
                                : Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasItemDetails
                                ? "تم تعبئة البيانات"
                                : "بيانات المنتج",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (controller.AddToItemAndInventory)
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: IconButton(
                    color: Colors.white,
                    iconSize: 40,
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      if (controller.camera != null) {
                        await controller.camera!.dispose();
                        controller.camera = null;
                        controller.cameraReady = false;
                        controller.update();
                      }

                      final code = await Get.to<String>(
                        () => const BarcodeScannerView(),
                      );

                      if (code != null) {
                        controller.ItemUpc = code;
                      }

                      // ✅ مهلة زمنية تسمح لنظام الأندرويد يحرر الكاميرا فعلياً
                      await Future.delayed(const Duration(milliseconds: 500));

                      // ✅ محاولة إعادة فتح الكاميرا مع إعادة محاولة تلقائية لو فشلت أول مرة
                      bool started = false;
                      for (
                        int attempt = 0;
                        attempt < 3 && !started;
                        attempt++
                      ) {
                        try {
                          await controller.initCamera();
                          started = controller.cameraReady;
                        } catch (e) {
                          started = false;
                        }
                        if (!started) {
                          await Future.delayed(
                            const Duration(milliseconds: 400),
                          );
                        }
                      }

                      controller.update();
                    },
                  ),
                ),

              Positioned(
                top: 40,
                right: 50,
                child: Text(
                  controller.ItemUpc.isNotEmpty
                      ? 'UPC: ${controller.ItemUpc}'
                      : '',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 248, 248, 248),
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    '${controller.images.length}/10',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () async {
                      if (controller.takingPhoto) return;

                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.lightImpact();
                      _showFlash();
                      await controller.takePicture(context);
                    },
                    child: const Icon(Icons.camera),
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 20,
                child: IconButton(
                  color: const Color.fromARGB(255, 91, 198, 41),
                  iconSize: 40,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Get.offAllNamed(Routes.home);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
