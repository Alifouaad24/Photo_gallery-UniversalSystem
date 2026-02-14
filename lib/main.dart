import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/api/api_methods.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/permission_service.dart';

String? token;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  StorageLocalService storageService = Get.put(StorageLocalService());
  token = storageService.readString('token');
  await PermissionService.requestCameraAndStorage();
  Get.put(DioClient());
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
