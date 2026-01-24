import 'package:get/get.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';

class GalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GalleryController());
  }
}
