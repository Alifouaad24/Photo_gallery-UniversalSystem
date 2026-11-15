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
  List<Map<String, dynamic>> Response = List.empty();
  @override
  void onInit() async {
    super.onInit();
    initializeSettings();
  }

  void selectBusiness(Business business) {
    selectedBusinessId = business.businessId;
    storageService.writeInt('business_id', business.businessId);
    storageService.writeString('business_Name', business.businessName);
    if (business.businessName == 'Duty') {
      storageService.writeString('product_key', 'upc');
    } else if (business.businessName == 'FHD') {
      storageService.writeString('product_key', 'sku');
    }
     else if (business.businessName == 'SHEIN IRAQ') {
      storageService.writeString('product_key', 'sku');
    }
     else {
      storageService.writeString('product_key', '');
    }
    update();
  }

  Business? get selectedBusiness {
    if (userResponse == null || selectedBusinessId == null) return null;

    return userResponse!.businesses.firstWhere(
      (b) => b.businessId == selectedBusinessId,
      orElse: () {
        storageService.writeInt(
          'business_id',
          userResponse!.businesses.first.businessId,
        );
        return userResponse!.businesses.first;
      },
    );
  }

  Future<void> getMyGroups() async {
    var userId = storageService.readString('userId');
    final result = await authRepository.getMyGroups(userId ?? '');

    result.fold(
      (error) {
        Get.toNamed(Routes.login);
      },
      (data) {
        Response = data;
        selectedBusinessId = storageService.readInt('business_id');

        final savedGroup = storageService.readInt('group_id');
        final exists = Response.any((g) => g['businessGroupId'] == savedGroup);
        selectedGroupId = (savedGroup != null && savedGroup != 0 && exists)
            ? savedGroup
            : null;

        update();
        Get.toNamed(Routes.home);
      },
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
        storageService.writeString('usaerName', data.userName);

        selectedBusinessId = storageService.readInt('business_id');
        if (selectedBusinessId == null &&
            userResponse != null &&
            userResponse!.businesses.isNotEmpty) {
          storageService.writeInt(
            'business_id',
            userResponse!.businesses.first.businessId,
          );
          storageService.writeString(
            'business_Name',
            userResponse!.businesses.first.businessName,
          );
        }

        update();
        Get.toNamed(Routes.home);
      },
    );
    await getMyGroups();
  }

  int? selectedGroupId;

Map<String, dynamic>? get selectedGroup {
  if (selectedGroupId == null) return null;
  for (final g in Response) {
    if (g['businessGroupId'] == selectedGroupId) return g;
  }
  return null;
}

List<Business> get groupBusinesses {
  final all = userResponse?.businesses ?? [];
  final group = selectedGroup;

  // بدون group: كل البزنس
  if (group == null) return all;

  final ids = (group['businessGroupBusinesses'] as List? ?? [])
      .map((e) => (e as Map)['business_id'])
      .toSet();

  return all.where((b) => ids.contains(b.businessId)).toList();
}

void selectGroup(int? id) {
  selectedGroupId = id;
  storageService.writeInt('group_id', id ?? 0); // 0 = بدون group

  final businesses = groupBusinesses;
  final currentStillInList =
      businesses.any((b) => b.businessId == selectedBusinessId);

  if (businesses.isNotEmpty && !currentStillInList) {
    selectBusiness(businesses.first);
  } else {
    update();
  }
}

  @override
  void onClose() {
    super.onClose();
  }
}
