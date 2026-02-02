import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:photo_gallery/modules/add-items/controllers/Add_Item-controller.dart';
import 'package:photo_gallery/modules/add-items/widgets/BarcodeOverlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AddItemController>(
        builder: (controller) => Stack(
          children: [
            MobileScanner(
              onDetect: (barcode) {
                if (!controller.scanMode) return;

                final code = barcode.barcodes.first.rawValue;
                if (code != null) {
                  var added = controller.addBarcode(code);
                  if (added) {
                    showFlash(context);
                  }
                  controller.scanMode = false;
                  controller.update();
                }
              },
            ),

            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'photo',
                    child: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      await controller.takePhoto();
                    },
                  ),
                  if (controller.barcodes == null)
                    FloatingActionButton(
                      heroTag: 'barcode',
                      child: const Icon(Icons.qr_code),
                      onPressed: () {
                        controller.setScanMode();
                      },
                    ),
                ],
              ),
            ),
            if (controller.scanMode)
              const IgnorePointer(ignoring: true, child: BarcodeOverlay()),
          ],
        ),
      ),
    );
  }

  void showFlash(BuildContext context) {
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
}
