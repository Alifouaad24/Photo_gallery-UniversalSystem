import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:photo_gallery/app/routes/app_routes.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/repository/auth_repository.dart';
import 'package:photo_gallery/models/splashResponseModel.dart';

class SplashController extends GetxController {
  AuthRepository authRepository = AuthRepository();
  StorageLocalService storageService = Get.find<StorageLocalService>();
  UserResponse? userResponse;
  int? selectedBusinessId;

  @override
  void onInit() {
    super.onInit();
    initializeSettings();
    selectedBusinessId = storageService.readInt('business_id');
  }

   void selectBusiness(Business business) {
    selectedBusinessId = business.businessId;
    storageService.writeInt('business_id', business.businessId);
    update();
  }

  Business? get selectedBusiness {
    if (userResponse == null || selectedBusinessId == null) return null;

    return userResponse!.businesses.firstWhere(
      (b) => b.businessId == selectedBusinessId,
      orElse: () => userResponse!.businesses.first,
    );
  }

  Future<void> initializeSettings() async {
    final result = await authRepository.GetMyData();

    result.fold(
      (error) {
        Get.toNamed(Routes.login);
      },
      (data) {
        userResponse = data;
        Get.toNamed(Routes.home);
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
