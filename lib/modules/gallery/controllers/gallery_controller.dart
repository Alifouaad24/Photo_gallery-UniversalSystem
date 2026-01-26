import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:photo_gallery/app/services/storage_service.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';
import 'package:photo_gallery/models/photo_session.dart';

class GalleryController extends GetxController {
  final galleryRepo = GalleryRepository();
  late PhotoSession session;
  final Set<int> selectedIndexes = {};
  bool isLoading = false;

   Map<DateTime, List<PhotoSession>> groupedSessions = {};

  Future<void> loadSessions() async {
    groupedSessions = await StoragePhotoService.loadSessions();
    update();
  }
  void toggleSelection(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
    update();
  }

  void clearSelection() {
    selectedIndexes.clear();
    update();
  }

  Future<void> uploadImages(List<File> files) async {
    isLoading = true;
    update();
    final result = await galleryRepo.uploadImages(files);
    result.fold(
      (error) {
        isLoading = false;
        update();
        Get.snackbar(
          'Error',
          error,
          backgroundColor: const Color(0xFFFF4C4C),
          colorText: Colors.white,
        );
      },
      (message) {
        isLoading = false;
        update();
        Get.snackbar(
          'Success',
          message,
          backgroundColor: const Color(0xFF4BB543),
          colorText: Colors.white,
        );
        clearSelection();
      },
    );
    isLoading = false;
    update();
  }

  Future<String?> scanBarcodeFromImage(File barcodeImage) async {
    final inputImage = InputImage.fromFile(barcodeImage);
    final scanner = BarcodeScanner();

    try {
      final barcodes = await scanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        Get.snackbar(
          'Barcode Found',
          barcodes.first.rawValue ?? '',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        saveTextAsImage(
          text: barcodes.first.rawValue ?? '',
          folderPath: barcodeImage.parent.path,
        );
        return barcodes.first.rawValue;
      } else {
        Get.snackbar(
          'No Barcode Found',
          'No barcode could be detected in this image.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } finally {
      await scanner.close();
    }
  }

  Future<File> saveTextAsImage({
    required String text,
    required String folderPath,
  }) async {
    const width = 600;
    const height = 200;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final paint = ui.Paint()..color = ui.Color(0xFFFFFFFF);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    // النص
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Color(0xFF000000),
          fontSize: 42,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        (height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    final file = File('$folderPath/barcode_number.png');
    return await file.writeAsBytes(byteData!.buffer.asUint8List());
  }

  Future<void> deleteSelectedImages() async {
  isLoading = true;
  update();

  final indexes = selectedIndexes.toList()..sort((a, b) => b.compareTo(a));

  for (final index in indexes) {
    final file = session.images[index];

    if (await file.exists()) {
      await file.delete();
    }

    session.images.removeAt(index);
  }

  selectedIndexes.clear();
  
  groupedSessions = await StoragePhotoService.loadSessions();
  isLoading = false;
  update();
}

}
