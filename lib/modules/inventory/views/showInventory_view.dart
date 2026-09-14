import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/models/inventoryModel.dart';
import 'package:photo_gallery/modules/camera/controllers/camera_controller.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';
import 'package:photo_gallery/modules/inventory/views/BarcodeScannerView.dart';
import 'package:photo_gallery/modules/inventory/views/EditInventoryResult.dart';

/// -------- Design tokens --------
class _Palette {
  static const bg = Color(0xFFF4F6F9);
  static const card = Colors.white;
  static const border = Color(0xFFEDEFF3);
  static const ink = Color(0xFF1B1F27);
  static const inkMuted = Color(0xFF6B7280);
  static const primary = Color(0xFF3457D5);
  static const primarySoft = Color(0xFFEFF2FF);
  static const success = Color(0xFF1CA97C);
  static const successSoft = Color(0xFFE7F8F2);
  static const danger = Color(0xFFE0473A);
  static const dangerSoft = Color(0xFFFCEBEA);
  static const amber = Color(0xFFB6790A);
  static const amberSoft = Color(0xFFFCF3E1);
}

class ShowinventoryView extends StatelessWidget {
  ShowinventoryView({super.key});
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      appBar: AppBar(
        backgroundColor: _Palette.card,
        elevation: 0,
        foregroundColor: _Palette.ink,
        title: const Text(
          "Inventory",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Inventory Found", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 14),
                  _cameraButton(onTap: () async {
                    var cameraController = Get.find<CameraGetController>();
                    cameraController.AddToItemAndInventory = true;
                    cameraController.ItemUpc = '';
                    cameraController.update();
                    final changed = await Get.toNamed(Routes.cameraSession);
                    if (changed == true) {
                      Get.toNamed(Routes.gallery);
                    }
                  }),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
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
                                  hintStyle: TextStyle(
                                    color: _Palette.inkMuted,
                                    fontSize: 13,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: _Palette.inkMuted,
                                  ),
                                  filled: true,
                                  fillColor: _Palette.card,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: _Palette.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: _Palette.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: _Palette.primary,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            InkWell(
                              borderRadius: BorderRadius.circular(16),
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
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: _Palette.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _Palette.primary.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner_rounded,
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
                            const SizedBox(height: 14),
                            _cameraButton(onTap: () async {
                              var cameraController =
                                  Get.find<CameraGetController>();
                              cameraController.AddToItemAndInventory = true;
                              cameraController.ItemUpc = '';
                              cameraController.update();

                              final changed = await Get.toNamed(
                                Routes.cameraSession,
                              );

                              if (changed == true) {
                                Get.toNamed(Routes.gallery);
                              }
                            }),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 6, bottom: 16),
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

Widget _cameraButton({required VoidCallback onTap}) {
  return OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Icons.camera_alt_rounded),
    label: const Text("Camera"),
    style: OutlinedButton.styleFrom(
      foregroundColor: _Palette.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      side: const BorderSide(color: _Palette.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

Widget inventoryCard(InventoryModel item) {
  final isBiometric = item.isBiometricComplete;

  final categoryName =
      item.category?.name ?? item.item?.category?.name ?? "-";
  final description =
      item.productDescription ?? item.item?.description ?? "-";
  final details = item.notes ?? item.item?.itemDetails ?? "-";
  final price = item.sitePrice ??
      (item.item?.basePrice != null ? "${item.item!.basePrice}" : "-");
  final status = item.status ?? "-";
  final qtyInStock = item.qty ?? 0;
  final upc = item.upc ?? item.item?.upc ?? "-";
  final model = item.model ?? item.item?.model ?? "-";
  final hasImage = item.item?.images.isNotEmpty ?? false;

  return GetBuilder<InventoryController>(
    builder: (controller) => InkWell(
      borderRadius: BorderRadius.circular(20),
      onLongPress: () {
        showEditInventoryDialog(
          item,
          categories: controller.categories,
          conditions: controller.conditions,
          onSave: (result) async {
            //await controller.updateInventoryItem(item.inventoryId!, result);
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _Palette.card,
          border: Border.all(color: _Palette.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= Header: image + name + badges =================
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: hasImage
                          ? Image.network(
                              item.item!.images.first.imageUrl ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: _Palette.bg,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: _Palette.inkMuted,
                                ),
                              ),
                            )
                          : Container(
                              color: _Palette.bg,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: _Palette.inkMuted,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: _Palette.ink,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _pillBadge(
                              icon: Icons.sell_outlined,
                              label: categoryName,
                              fg: _Palette.primary,
                              bg: _Palette.primarySoft,
                            ),
                            _pillBadge(
                              icon: isBiometric
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              label: "Biometric",
                              fg: isBiometric
                                  ? _Palette.success
                                  : _Palette.danger,
                              bg: isBiometric
                                  ? _Palette.successSoft
                                  : _Palette.dangerSoft,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// Price - right aligned accent
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "السعر",
                        style: TextStyle(
                          fontSize: 10,
                          color: _Palette.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _Palette.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: _Palette.border),

            /// ================= Body: description / details / upc / model =================
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailLine(
                    icon: Icons.description_outlined,
                    label: "الوصف",
                    value: description,
                  ),
                  const SizedBox(height: 10),
                  _detailLine(
                    icon: Icons.list_alt_rounded,
                    label: "التفاصيل",
                    value: details,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _detailLine(
                          icon: Icons.qr_code_rounded,
                          label: "UPC",
                          value: upc,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _detailLine(
                          icon: Icons.memory_rounded,
                          label: "Model",
                          value: model,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: _Palette.border),

            /// ================= Footer: status + qty (قسم مستقل بالمخزن) =================
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.info_outline_rounded,
                      label: "الحالة",
                      value: status,
                      fg: _Palette.amber,
                      bg: _Palette.amberSoft,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    icon: Icons.inventory_2_outlined,
                    label: "الكمية",
                    value: "$qtyInStock",
                    fg: _Palette.primary,
                    bg: _Palette.primarySoft,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _pillBadge({
  required IconData icon,
  required String label,
  required Color fg,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    ),
  );
}

Widget _detailLine({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _Palette.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 14, color: _Palette.inkMuted),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: _Palette.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: _Palette.ink,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _statCard({
  required IconData icon,
  required String label,
  required String value,
  required Color fg,
  required Color bg,
  bool compact = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    constraints: compact ? const BoxConstraints(minWidth: 84) : null,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: 8),
        compact
            ? Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              )
            : Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: fg.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    ),
  );
}

void showQtyDialog(
  InventoryModel item, {
  required Function(int qty) onConfirm,
}) {
  final TextEditingController qtyController = TextEditingController();

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "ادخل الكمية للمنتج ${item.item?.upc ?? ""}",
        style: TextStyle(fontSize: 16),
      ),
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
          builder: (controller) => ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text);
              if (qty == null) {
                Get.snackbar("خطأ", "أدخل كمية صحيحة");
                return;
              }
              onConfirm(qty);
            },
            child: controller.changeQty
                ? CircularProgressIndicator()
                : Text("موافق"),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}