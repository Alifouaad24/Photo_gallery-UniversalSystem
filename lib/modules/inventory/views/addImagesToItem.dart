import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';

class Addimagestoitem extends StatefulWidget {
  const Addimagestoitem({super.key});

  @override
  State<Addimagestoitem> createState() => _AddimagestoitemState();
}

class _AddimagestoitemState extends State<Addimagestoitem> {
  final InventoryController controller = Get.find<InventoryController>();

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

  @override
  void dispose() {
    // تصحيح: قبل كده كان بينادي controller.endCameraSession() هنا، وده
    // كان بيصفّر ويمسح كل الصور اللي اتلقطت (images.clear()) بمجرد
    // الخروج من الشاشة — يعني الصور بتتفقد قبل ما توصل لزرار "حفظ
    // المنتج" في الشاشة اللي قبلها. دلوقتي بنسيب هاردوير الكاميرا بس؛
    // إنهاء الجلسة الفعلي (ومسح المجلد لو المستخدم ما التقطش صور) بيحصل
    // من الشاشة اللي قبلها (Addnewitemtoinventory) حسب النتيجة النهائية.
    controller.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تصحيح: كانت الشاشة متلفوفة بـ GetBuilder<CameraGetController>
    // رغم إن كل الحالة اللي بتتقرا وبتتحدث (cameraReady, camera, images,
    // takingPhoto) هي حالة InventoryController، فأي update() في
    // InventoryController مكانش بيعمل rebuild للواجهة خالص.
    return GetBuilder<InventoryController>(
      builder: (_) {
        if (!controller.cameraReady || controller.camera == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(
                  key: ValueKey(controller.camera.hashCode),
                  controller.camera!,
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

              /// زرار X: دلوقتي بيرجع بس للشاشة اللي قبله (Addnewitemtoinventory)
              /// من غير ما يمسح أو يرفع أي حاجة هنا. الشاشة اللي قبلها هي
              /// اللي هتقرر تظهر زرار "حفظ المنتج" ولا لأ بناءً على عدد
              /// الصور اللي اتجمعت في controller.images.
              Positioned(
                bottom: 40,
                left: 20,
                child: IconButton(
                  color: const Color.fromARGB(255, 91, 198, 41),
                  iconSize: 40,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Get.back();
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