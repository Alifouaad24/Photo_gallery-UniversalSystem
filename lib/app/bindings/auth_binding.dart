import 'package:get/get.dart';
import 'package:photo_gallery/modules/auth/controllers/AuthController.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
