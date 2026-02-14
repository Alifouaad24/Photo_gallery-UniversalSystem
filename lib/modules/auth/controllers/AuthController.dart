import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/repository/auth_repository.dart';
import 'package:photo_gallery/main.dart';
import 'package:photo_gallery/models/splashResponseModel.dart';
import 'package:photo_gallery/modules/splash/controllers/splash_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageLocalService _storageService = Get.find<StorageLocalService>();
  StorageLocalService storageService = Get.find<StorageLocalService>();
  final SplashController _splashController = Get.put(SplashController());

  UserResponse? userResponse;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  int? selectedBusinessId;
  Future<void> login() async {
    loading = true;
    update();
    final result = await _authRepository.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
    );

    result.fold(
      (error) {
        Get.snackbar(
          'Login Failed',
          error,
          snackPosition: SnackPosition.BOTTOM,
        );
        loading = false;
        update();
      },
      (user) async {
        loading = false;
        update();
        _storageService.writeString('token', user.token);
        Future.delayed(const Duration(milliseconds: 500), () {});
        token = user.token;
        await _splashController.initializeSettings();
      },
    );
  }

  void logout() {
    _storageService.remove('token');
    _storageService.remove('business_id');
    Get.offAllNamed(Routes.login);
  }
}
