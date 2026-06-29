import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/local/data_base.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';
import 'package:sqflite/sqflite.dart';

class CameraGetController extends GetxController {
  final galleryRepo = GalleryRepository();
  final StorageLocalService storageService = Get.find<StorageLocalService>();

  Database? db;
  CameraController? camera;

  Directory? sessionFolder;
  int? currentFolderId;

  bool isLoading = false;
  bool cameraReady = false;

  List<Map<String, dynamic>> images = [];

  @override
  void onInit() async {
    super.onInit();
    db = await DatabaseHelper().database;
  }

  // ================= CAMERA =================

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    camera = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await camera!.initialize();
    cameraReady = true;
    update();
  }

  Future<void> disposeCamera() async {
    if (camera != null) {
      await camera!.dispose();
      camera = null;
      cameraReady = false;
      currentFolderId = null;
    }
  }

  // ================= SESSION =================

  Future<void> startCameraSession() async {
    print(
      '########################################################currentFolderId: $currentFolderId',
    );
    final dir = await getApplicationDocumentsDirectory();
    final mainFolder = Directory('${dir.path}/ApxGallery');

    if (!await mainFolder.exists()) {
      await mainFolder.create(recursive: true);
    }

    if (currentFolderId != null) {
      sessionFolder = Directory('${mainFolder.path}/$currentFolderId');
    } else {
      final folderName = DateTime.now()
          .toString()
          .substring(0, 19)
          .replaceAll(' ', '|');
      currentFolderId = await db!.insert('folder', {
        'name': folderName,
        'business_name': storageService.readString('business_Name') ?? '',
      });
      print(currentFolderId);
      print(storageService.readString('business_Name'));
      sessionFolder = Directory('${mainFolder.path}/$currentFolderId');
    }

    if (!await sessionFolder!.exists()) {
      await sessionFolder!.create(recursive: true);
    }

    images.clear();
    update();
  }

  Future<void> endCameraSession() async {
    await disposeCamera();
    sessionFolder = null;
    currentFolderId = null;
    images.clear();
    if (images.isEmpty && sessionFolder != null) {
      await sessionFolder!.delete(recursive: true);
      await db!.delete('folder', where: 'id=?', whereArgs: [currentFolderId]);
    }
    update();
  }

  // ================= CAPTURE =================

  bool takingPhoto = false;

  Future<void> takePicture() async {
    if (!cameraReady ||
        camera == null ||
        images.length >= 10 ||
        sessionFolder == null)
      return;

    takingPhoto = true;
    update();

    final xFile = await camera!.takePicture();

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${sessionFolder!.path}/$fileName';
    final newImage = await File(xFile.path).copy(newPath);

    // احفظها محلياً أولاً
    final id = await db!.insert('image', {
      'folder_id': currentFolderId,
      'name': newImage.path,
      'isUploaded': 0,
    });

    images.add({'id': id, 'name': newImage.path, 'isUploaded': 0});

    takingPhoto = false;
    update();

    // ارفعها في الخلفية
    _uploadImageInBackground(id, newImage);
  }

  Future<void> _uploadImageInBackground(int id, File file) async {
    final uploaded = await uploadImages(file);

    if (uploaded) {
      await db!.update(
        'image',
        {'isUploaded': 1},
        where: 'id=?',
        whereArgs: [id],
      );

      final index = images.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        images[index]['isUploaded'] = 1;
        update();
      }
    }
  }

  // ================= UPLOAD =================

  Future<bool> uploadImages(File file) async {
    int businessId = storageService.readInt('business_id') ?? 0;

    if (businessId == 0) return false;

    isLoading = true;
    update();

    final result = await galleryRepo.uploadImages(
      [file],
      businessId,
      currentFolderId!,
    );

    bool success = false;

    result.fold((_) => success = false, (_) => success = true);

    isLoading = false;
    update();

    return success;
  }
}
