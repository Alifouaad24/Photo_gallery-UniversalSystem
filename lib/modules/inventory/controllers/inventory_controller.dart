import 'package:get/get.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/repository/inventory_repository.dart';
import 'package:photo_gallery/models/inventoryModel.dart';

class InventoryController extends GetxController {
  final inventoryRepo = InventoryRepository();
  final StorageLocalService _storageService = Get.find<StorageLocalService>();
  bool isLoading = false;
  List<InventoryModel> inventoryList = [];
  String? errorMessage;
  List<InventoryModel> filteredInventory = [];
  bool changeQty = false;

  @override
  void onInit() {
    super.onInit();
    var businessId = _storageService.readInt('business_id');
    if (businessId != null) {
      getInventory(businessId);
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
}
