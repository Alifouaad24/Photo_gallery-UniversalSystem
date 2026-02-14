import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
import 'package:camera/camera.dart';

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
    await controller.initCamera();
    await controller.startCameraSession();
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
    controller.endCameraSession();
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
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: CameraPreview(controller.camera!)),

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
                      SystemSound.play(SystemSoundType.click);
                      HapticFeedback.lightImpact();
                      await controller.takePicture();
                      _showFlash();
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
                  icon: const Icon(Icons.save),
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
