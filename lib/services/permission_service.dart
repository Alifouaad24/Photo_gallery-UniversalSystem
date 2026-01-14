import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraAndStorage() async {
    final cameraStatus = await Permission.camera.request();

    final storageStatus = await Permission.photos.request();

    return cameraStatus.isGranted && storageStatus.isGranted;
  }
}
