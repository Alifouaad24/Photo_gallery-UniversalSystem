import 'package:get/get.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/repository/inventory_repository.dart';
import 'package:photo_gallery/models/inventoryModel.dart';
import 'package:photo_gallery/modules/inventory/views/EditInventoryResult.dart';

class InventoryController extends GetxController {
  final inventoryRepo = InventoryRepository();
  final StorageLocalService _storageService = Get.find<StorageLocalService>();
  bool isLoading = false;
  List<InventoryModel> inventoryList = [];
  List<CategoryModel> categories = [];
  List<ItemConditionModel> conditions = [];
  String? errorMessage;
  List<InventoryModel> filteredInventory = [];
  bool changeQty = false;

  @override
  void onInit() {
    super.onInit();
    var businessId = _storageService.readInt('business_id');
    if (businessId != null) {
      getInventory(businessId);
      getConditions();
      getCategories(businessId);
    }
  }

  Future<void> getInventory(int busId) async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getInvByBusiness(busId);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        inventoryList = data;
        filteredInventory = List.from(data);
      },
    );

    isLoading = false;
    update();
  }

  Future<void> getConditions() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getAllConditions();

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        conditions = data;
      },
    );

    isLoading = false;
    update();
  }

  Future<void> getCategories(int busId) async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getAllCategories(busId);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        categories = data;
      },
    );

    isLoading = false;
    update();
  }

  void searchInventory(String value) {
    if (value.trim().isEmpty) {
      filteredInventory = List.from(inventoryList);
    } else {
      final text = value.toLowerCase();

      filteredInventory = inventoryList.where((e) {
        return (e.productName ?? "").toLowerCase().contains(text) ||
            (e.item?.model ?? "").toLowerCase().contains(text) ||
            (e.item?.upc ?? "").toLowerCase().contains(text) ||
            (e.sku ?? "").toLowerCase().contains(text);
      }).toList();
    }

    update();
  }

  Future<void> updateInvItemQty(int inventoryId, int qty) async {
    changeQty = true;
    update();

    final result = await inventoryRepo.changeInvItemQty(inventoryId, qty);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        final index = inventoryList.indexWhere(
          (inv) => inv.inventoryId == inventoryId,
        );

        if (index != -1) {
          final updatedItem = inventoryList[index].copyWith(qty: data.qty);

          inventoryList[index] = updatedItem;

          final fIndex = filteredInventory.indexWhere(
            (inv) => inv.inventoryId == inventoryId,
          );

          if (fIndex != -1) {
            filteredInventory[fIndex] = updatedItem;
          }
        }

        update();
      },
    );

    changeQty = false;
    Get.back();
    update();
  }

  ////////////////////////////////////////////////////////////////////////
  ///
  bool isSavingItem = false;
  bool isUploadingImages = false;
  Future<void> updateInventoryItem(
    int inventoryId,
    EditInventoryResult result,
  ) async {
    isSavingItem = true;
    errorMessage = null;
    update();

    // -------- الخطوة 1: رفع الصور أولاً (لو فيه صور جديدة) --------
    List<String> uploadedImageUrls = [];

    if (result.newImages.isNotEmpty) {
      isUploadingImages = true;
      update();

      final uploadResult = await inventoryRepo.uploadInventoryImages(
        result.newImages,
      );

      isUploadingImages = false;

      bool uploadFailed = false;

      uploadResult.fold(
        (error) {
          uploadFailed = true;
          errorMessage = error.toString();
          Get.snackbar("خطأ", "تعذر رفع الصور، حاول مرة أخرى");
        },
        (urls) {
          uploadedImageUrls = urls;
        },
      );

      if (uploadFailed) {
        isSavingItem = false;
        update();
        return; // نوقف العملية لو فشل رفع الصور - ما نكمل تحديث البيانات
      }
    }

    // -------- الخطوة 2: تجهيز JSON بكل الباراميترات وإرساله --------
    final apiResult = await inventoryRepo.updateInventoryItem(
      inventoryId: inventoryId,
      categoryId: result.category?.categoryId,
      itemConditionId: result.condition?.itemConditionId,
      description: result.description,
      details: result.details,
      itemPrice: result.itemPrice,
      warehousePrice: result.warehousePrice,
      imageUrls: uploadedImageUrls,
    );

    apiResult.fold(
      (error) {
        errorMessage = error.toString();
        Get.snackbar("خطأ", "تعذر حفظ التعديلات");
      },
      (data) {
        final index = inventoryList.indexWhere(
          (inv) => inv.inventoryId == inventoryId,
        );

        if (index != -1) {
          inventoryList[index] = data;

          final fIndex = filteredInventory.indexWhere(
            (inv) => inv.inventoryId == inventoryId,
          );

          if (fIndex != -1) {
            filteredInventory[fIndex] = data;
          }
        }

        Get.snackbar("تم", "تم تحديث بيانات العنصر بنجاح");
      },
    );

    isSavingItem = false;
    update();
  }
}
