import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/app/services/backGroundUploader.dart';
import 'package:photo_gallery/data/api/api_methods.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/permission_service.dart';

String? token;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  StorageLocalService storageService = Get.put(StorageLocalService());
  final backgroundUploader = Get.put(
    BackgroundUploaderService(
      storageService: storageService,
      galleryRepository: GalleryRepository(),
    ),
    permanent: true,
  );
  token = storageService.readString('token');
  await PermissionService.requestCameraAndStorage();
  Get.put(DioClient());
  Get.put(CameraGetController());
  await backgroundUploader.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Photo Gallery',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      theme: ThemeData.dark(),
    );
  }
}
