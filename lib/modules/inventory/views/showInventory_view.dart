import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/inventoryModel.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';
import 'package:photo_gallery/modules/inventory/views/BarcodeScannerView.dart';

class ShowinventoryView extends StatelessWidget {
  ShowinventoryView({super.key});
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(title: const Text("Inventory")),
      body: GetBuilder<InventoryController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          if (controller.inventoryList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment .center,
                children: [
                  Text("No Inventory Found", style: TextStyle(fontSize: 18)),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final changed = await Get.toNamed(Routes.cameraSession);

                      if (changed == true) {
                        Get.toNamed(Routes.gallery);
                      }
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text("Camera"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Autocomplete<InventoryModel>(
                  displayStringForOption: (item) =>
                      "${item.productName} (${item.item?.upc ?? ""})",

                  optionsBuilder: (TextEditingValue value) {
                    if (value.text.isEmpty) {
                      return controller.inventoryList;
                    }

                    return controller.inventoryList.where((item) {
                      final text = value.text.toLowerCase();

                      return (item.productName ?? "").toLowerCase().contains(
                            text,
                          ) ||
                          (item.item?.model ?? "").toLowerCase().contains(
                            text,
                          ) ||
                          (item.item?.upc ?? "").toLowerCase().contains(text);
                    });
                  },

                  onSelected: (item) {
                    controller.filteredInventory = [item];
                    controller.update();
                  },

                  fieldViewBuilder:
                      (context, textController, focusNode, onSubmit) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: controller.searchInventory,
                                decoration: InputDecoration(
                                  hintText: "Search UPC, Model, Product...",
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () async {
                                final code = await Get.to<String>(
                                  () => const BarcodeScannerView(),
                                );

                                if (code != null) {
                                  searchController.text = code;
                                  controller.searchInventory(code);
                                }
                              },
                              child: Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                ),
              ),

              Expanded(
                child: controller.filteredInventory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "No Results Found",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),

                            OutlinedButton.icon(
                              onPressed: () async {
                                final changed = await Get.toNamed(
                                  Routes.cameraSession,
                                );

                                if (changed == true) {
                                  Get.toNamed(Routes.gallery);
                                }
                              },
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text("Camera"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.filteredInventory.length,
                        itemBuilder: (_, index) {
                          return inventoryCard(
                            controller.filteredInventory[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget inventoryCard(InventoryModel item) {
  return GetBuilder<InventoryController>(
    builder: (controller) => 
     InkWell(
      onLongPress: () {
        showQtyDialog(
          item,
          onConfirm: (qty) {
            controller.updateInvItemQty(item.inventoryId!, qty);
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 221, 215, 215),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              /// Image
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item.item?.images.first.imageUrl ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
    
              const SizedBox(width: 14),
    
              /// Middle content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
    
                    const SizedBox(height: 10),
    
                    _infoRow(Icons.qr_code_rounded, item.item?.upc ?? "-"),
                    const SizedBox(height: 6),
                    _infoRow(Icons.memory_rounded, item.item?.model ?? "-"),
                  ],
                ),
              ),
    
              const SizedBox(width: 5),
    
              /// Qty badge (modern chip)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color.fromARGB(255, 14, 15, 15).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Qty",
                      style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 9, 9, 9)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.qty}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 16, 17, 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _infoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 14, color: const Color.fromARGB(255, 37, 33, 33)),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

void showQtyDialog(InventoryModel item, {required Function(int qty) onConfirm}) {
  final TextEditingController qtyController = TextEditingController();

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("ادخل الكمية للمنتج ${item.item?.upc ?? ""}", style: TextStyle(fontSize: 16),),
      content: TextField(
        controller: qtyController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
        GetBuilder<InventoryController>(
          builder: (controller) => 
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text);
              if (qty == null) {
                Get.snackbar("خطأ", "أدخل كمية صحيحة");
                return;
              }
              onConfirm(qty);
            },
            child: controller.changeQty ? CircularProgressIndicator() : Text("موافق"),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
