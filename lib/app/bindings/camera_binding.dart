import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraGetController>(() => CameraGetController());
  }
}
