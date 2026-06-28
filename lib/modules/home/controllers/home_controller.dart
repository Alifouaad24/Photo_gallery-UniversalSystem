import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photo_gallery/app/services/AppRealese.dart';
import 'package:photo_gallery/app/services/StorageService.dart';

class HomeController extends GetxController {
  final StorageLocalService storageService = Get.find<StorageLocalService>();
  String version = '';

  static const String releaseDate = AppRelease.ReleaseDate;
  String get userName => storageService.readString("usaerName") ?? "";
 
  @override
  void onInit() {
    super.onInit();
    loadVersion();
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version = '${info.version} (${info.buildNumber})';
    update();
  }
}