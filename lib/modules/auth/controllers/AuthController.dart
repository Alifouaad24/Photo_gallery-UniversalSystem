import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/app/services/storage_service.dart';
import 'package:photo_gallery/data/repository/auth_repository.dart';

class AuthController extends GetxController {

  final AuthRepository _authRepository = AuthRepository();
  final StorageLocalService _storageService = Get.find<StorageLocalService>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

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
      (token) {
        loading = false;
        update();
        _storageService.writeString('token', token);
        Get.snackbar(
          'Login Successful',
          'Welcome!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.toNamed(Routes.home);
      },
    );
  }
}
