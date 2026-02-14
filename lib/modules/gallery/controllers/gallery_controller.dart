import 'dart:io';
import 'dart:ui';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/local/data_base.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';
import 'package:photo_gallery/models/folderModel.dart';
import 'package:photo_gallery/models/photo_session.dart';
import 'package:sqflite/sqflite.dart';

class GalleryController extends GetxController {
  late Database db;
  final galleryRepo = GalleryRepository();
  int? folderId;
  final Set<ImageItem> selectedIndexes = {};
  bool isLoading = false;
  StorageLocalService storageService = Get.find<StorageLocalService>();
  List<Map<String, dynamic>> groupedSessions = [];
  List<Folder> Sessions = [];
  Directory? constFolder;
  List<ImageItem> currentImages = [];
  Folder? currentFolder;
  String? currentFolderName;
  late File currentImage;

  @override
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    db = await DatabaseHelper().database;
    constFolder = Directory('${dir.path}/ApxGallery');
    await loadSessions();
  }

  Future<void> setFolder() async {
    final folders = await db.query(
      'folder',
      where: 'id = ?',
      whereArgs: [folderId],
    );

    if (folders.isEmpty) {
      currentFolder = null;
      currentFolderName = null;
      currentImages = [];
      update(); // تحديث الـ GetBuilder
      return;
    }

    final foldersRec = folders.map((json) => Folder.fromMap(json)).toList();
    currentFolder = foldersRec.first;
    currentFolderName = foldersRec.first.name;

    final images = await db.query(
      'image',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
    currentImages = images.map((json) => ImageItem.fromMap(json)).toList();
    if (currentImages.isEmpty) {
      await db.delete('folder', where: 'id = ?', whereArgs: [folderId]);
      folderId = null;
      Get.toNamed(Routes.gallery);
    }

    update();
  }

  Future<File?> getCoverImage(int folderId) async {
    final result = await db.query(
      'image',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'id ASC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    final image = ImageItem.fromMap(result.first);
    final file = File(image.name);

    if (!await file.exists()) return null;

    return file;
  }

Future<void> loadSessions() async {
    groupedSessions = await db.query('folder', orderBy: 'id DESC');
    Sessions.clear();
    Sessions = groupedSessions.map((e) => Folder.fromMap(e)).toList();
    for(var s in Sessions){
      print(s.name);
    }
    update();
}

  List<String> sesion = [];

  void toggleSelection(ImageItem rec) {
    if (selectedIndexes.contains(rec)) {
      selectedIndexes.remove(rec);
      sesion.remove(rec.name); 
    } else {
      selectedIndexes.add(rec);
      sesion.add(rec.name);
    }
    update();
  }

  void clearSelection() {
    selectedIndexes.clear();
    update();
  }

  Future<int> getImgNumber(int folId) async {
    var data = await db.query(
      'image',
      where: 'folder_id = ?',
      whereArgs: [folId],
    );
    var images = data.map((e) => ImageItem.fromMap(e)).toList();
    return images.length;
  }

  Future<void> uploadImages(List<File> files) async {
    int businessId = storageService.readInt('business_id') ?? 0;
    if (businessId == 0) {
      Get.snackbar(
        'Error',
        'Business ID not found',
        backgroundColor: const Color(0xFFFF4C4C),
        colorText: Colors.white,
      );
      return;
    }
    isLoading = true;
    update();
    final result = await galleryRepo.uploadImages(files, businessId);
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

  // Future<void> handleScannedBarcode(
  //   String value, {
  //   required Directory sessionDir,
  // }) async {
  //   if (value.isEmpty) return;

  //   await saveTextAsImage(text: value, folderPath: sessionDir.path);

  //   groupedSessions = await StoragePhotoService.loadSessions();
  //   update();
  // }

  // Future<void> scanBarcodeFromImage(File barcodeImage) async {
  //   final inputImage = InputImage.fromFile(barcodeImage);
  //   final scanner = BarcodeScanner();

  //   try {
  //     final barcodes = await scanner.processImage(inputImage);

  //     if (barcodes.isNotEmpty) {
  //       final value = barcodes.first.rawValue ?? '';

  //       Get.snackbar(
  //         'Barcode Found',
  //         value,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );

  //       await saveTextAsImage(
  //         text: value,
  //         folderPath: barcodeImage.parent.path,
  //       );
  //       groupedSessions = await StoragePhotoService.loadSessions();
  //       update();
  //     } else {
  //       Get.snackbar(
  //         'No Barcode Found',
  //         'No barcode could be detected in this image.',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } finally {
  //     await scanner.close();
  //   }
  // }

  // Future<File> saveTextAsImage({
  //   required String text,
  //   required String folderPath,
  // }) async {
  //   const width = 600;
  //   const height = 200;

  //   final recorder = PictureRecorder();
  //   final canvas = Canvas(recorder);

  //   final paint = Paint()..color = Color(0xFFFFFFFF);
  //   canvas.drawRect(
  //     Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
  //     paint,
  //   );

  //   // النص
  //   final textPainter = TextPainter(
  //     text: TextSpan(
  //       text: text,
  //       style: TextStyle(
  //         color: Color(0xFF000000),
  //         fontSize: 42,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     textDirection: TextDirection.ltr,
  //   );

  //   textPainter.layout();
  //   textPainter.paint(
  //     canvas,
  //     Offset(
  //       (width - textPainter.width) / 2,
  //       (height - textPainter.height) / 2,
  //     ),
  //   );

  //   final picture = recorder.endRecording();
  //   final image = await picture.toImage(width, height);
  //   final byteData = await image.toByteData(format: ImageByteFormat.png);

  //   final file = File('$folderPath/barcode_number.png');
  //   uploadImages([file]);
  //   return await file.writeAsBytes(byteData!.buffer.asUint8List());
  // }

  Future<void> deleteSelectedImages() async {
    if (sesion == null || sesion.isEmpty) return;

    isLoading = true;
    update();

    final indexes = selectedIndexes.toList();
    for (final item in indexes) {
      await db.delete('image', where: 'name = ?', whereArgs: [item.name]);
    }

    for (final file in sesion!) {
      var realFile = File(file);
      if (await realFile.exists()) {
        await realFile.delete();
      }
    }

    selectedIndexes.clear();
    setFolder();
    isLoading = false;
    update();
  }

  Future<void> deleteSession(int id) async {
    isLoading = true;
    update();

    try {
      final images = await db.query(
        'image',
        where: 'folder_id = ?',
        whereArgs: [id],
      );

      final imgsRec = images.map((e) => ImageItem.fromMap(e)).toList();

      for (final img in imgsRec) {
        final path = img.name;
        final file = File(path);

        if (await file.exists()) {
          await file.delete();
        }
      }

      await db.delete('image', where: 'folder_id = ?', whereArgs: [id]);
      await db.delete('folder', where: 'id = ?', whereArgs: [id]);

      await loadSessions();
    } catch (e) {
      print('Delete error: $e');
    }

    isLoading = false;
    setFolder();
    update();
  }

  Future<void> cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: currentImage.path,
      uiSettings: [AndroidUiSettings(toolbarTitle: 'Crop')],
    );

    if (cropped == null) return;
    final name = 'crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${currentImage.parent.path}/$name';
    final newFile = File('${currentImage.parent.path}/$name');

    await newFile.writeAsBytes(await File(cropped.path).readAsBytes());
    await db.insert('image', {
      'name': newPath,
      'folder_id': currentFolder!.id,
      'isUploaded': 0,
    });
    currentImage = newFile;
    setFolder();
    update();
  }

  Future<void> rotateImage() async {
    final bytes = await currentImage.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) return;

    final rotated = img.copyRotate(original, angle: 90);
    final name = 'rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${currentImage.parent.path}/$name';

    final newFile = File(newPath);
    await newFile.writeAsBytes(img.encodeJpg(rotated));

    await db.insert('image', {
      'name': newPath,
      'folder_id': currentFolder!.id,
      'isUploaded': 0,
    });
    currentImage = newFile;
    setFolder();
    update();
  }

  // Future<void> SaveUpdated() async {
  //   final bytes = await currentImage.readAsBytes();
  //   final original = img.decodeImage(bytes);

  //   if (original == null) return;

  //   final rotated = img.copyRotate(original, angle: 90);
  //   final name = 'edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //   final newPath = '${currentImage.parent.path}/$name';

  //   final newFile = File(newPath);
  //   await newFile.writeAsBytes(img.encodeJpg(rotated));

  //   await db.insert('image', {
  //     'name': name,
  //     'folder_id': currentFolder!.id,
  //     'isUploaded': 0,
  //   });

  //   update();
  // }
}
