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
  int? currentLocalFolderId;
  int? remoteFolderIdCreated;

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
      '########################################################currentRemoteFolderId: $currentFolderId',
    );
    final dir = await getApplicationDocumentsDirectory();
    final mainFolder = Directory('${dir.path}/ApxGallery');

    if (!await mainFolder.exists()) {
      await mainFolder.create(recursive: true);
    }

    if (currentFolderId != null) {
      sessionFolder = Directory('${mainFolder.path}/$currentFolderId');
    } else {
      int remoteFolderId = await createRemoteFolder();
      
      currentFolderId = remoteFolderId;
      final folderName = DateTime.now()
          .toString()
          .substring(0, 19)
          .replaceAll(' ', '|');

      currentLocalFolderId = await db!.insert('folder', {
        'name': folderName,
        'business_name': storageService.readString('business_Name') ?? '',
        'serverId': remoteFolderId,
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
      await deleteRemoteFolder(remoteFolderIdCreated!);
      await db!.delete('folder', where: 'id=?', whereArgs: [currentLocalFolderId]);
    }
    update();
  }

  // ================= CAPTURE =================

  bool takingPhoto = false;

  Future<void> takePicture(BuildContext context) async {
    if (!cameraReady ||
        camera == null ||
        images.length >= 10 ||
        sessionFolder == null) {
      return;
    }

    takingPhoto = true;
    update();

    try {
      final xFile = await camera!.takePicture();

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${sessionFolder!.path}/$fileName';
      final newImage = await File(xFile.path).copy(newPath);

      // احفظها محلياً أولاً
      final id = await db!.insert('image', {
        'folder_id': currentLocalFolderId,
        'name': newImage.path,
        'server_id': 0,
        'server_addedDate': '',
        'isUploaded': 0,
      });

      images.add({'id': id, 'name': newImage.path, 'isUploaded': 0});

      // ارفعها في الخلفية
      _uploadImageInBackground(id, newImage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      takingPhoto = false;
      update();
    }
  }

  Future<void> _uploadImageInBackground(int id, File file) async {
    final uploaded = await uploadImages(file);

    if (uploaded['success']) {
      print('Image uploaded successfully: $uploaded');
      print(uploaded['serverImageId']);
      print(uploaded['serverImageId'].runtimeType);
      print(uploaded['insetDateInServer']);
      await db!.update(
        'image',
        {
          'isUploaded': 1,
          'server_id': uploaded['serverImageId'],
          'server_addedDate': uploaded['insetDateInServer'],
        },
        where: 'id=?',
        whereArgs: [id],
      );

      final realRow = await db!.query('image', where: 'id=?', whereArgs: [id]);
      print('Real row from DB: $realRow');

      final index = images.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        images[index]['isUploaded'] = 1;
        update();
      }
    }
  }

  // ================= UPLOAD =================

  Future<Map<String, dynamic>> uploadImages(File file) async {
    int businessId = storageService.readInt('business_id') ?? 0;

    if (businessId == 0) {
      return {'success': false, 'serverImageId': null};
    }

    isLoading = true;
    update();

    final result = await galleryRepo.uploadImages(
      [file],
      businessId,
      currentFolderId!,
    );

    final response = result.fold(
      (_) => {'success': false, 'serverImageId': null},
      (data) {
        print("RAW API DATA: $data");

        return {
          'success': true,
          'serverImageId': data['remoteImageId'],
          'insetDateInServer': data['insetDate'],
        };
      },
    );

    isLoading = false;
    update();

    return response;
  }

  Future<int> createRemoteFolder() async {
    isLoading = true;
    update();
    final result = await galleryRepo.createServerFolder();
    int folderId = result.fold(
      (error) {
        print(error);
        return 0;
      },
      (data) {
        return data['userFolderId'] as int;
      },
    );
    isLoading = false;
    update();

    return folderId;
  }

  Future<void> deleteRemoteFolder(int id) async {
    isLoading = true;
    update();
    final result = await galleryRepo.deleteRemoteFolder(id);
    result.fold((error) {}, (data) {});
    isLoading = false;
    update();
  }
}
