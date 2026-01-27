import 'package:get/get.dart';
import 'package:photo_gallery/modules/auth/controllers/AuthController.dart';
import 'package:photo_gallery/modules/home/controllers/home_controller.dart';
import 'package:photo_gallery/modules/splash/controllers/splash_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => SplashController());
    Get.lazyPut(()=>AuthController());
  }
}
