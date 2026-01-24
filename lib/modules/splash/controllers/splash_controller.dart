import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:photo_gallery/app/routes/app_routes.dart';
import 'package:photo_gallery/data/repository/auth_repository.dart';

class SplashController extends GetxController {
  AuthRepository authRepository = AuthRepository();
  @override
  void onInit() {
    super.onInit();
    initializeSettings();
  }

  Future<void> initializeSettings() async {
    final result = await authRepository.GetMyData();

    result.fold(
      (error) {
        Get.toNamed(Routes.login);
      },
      (data) {
        Get.toNamed(Routes.home);
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
