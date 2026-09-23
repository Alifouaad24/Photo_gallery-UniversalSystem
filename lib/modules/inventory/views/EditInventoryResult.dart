import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/models/inventoryModel.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';

/// البيانات اللي ترجع بعد الحفظ - يستخدمها Controller.updateInventoryItem
class EditInventoryResult {
  final CategoryModel? category;
  final ItemConditionModel? condition;
  final String description;
  final String details;
  final double? itemPrice; // سعر الايتم
  final double? warehousePrice; // سعر المخزن
  final List<File> newImages;
  final int? qty;

  EditInventoryResult({
    required this.category,
    required this.condition,
    required this.description,
    required this.details,
    required this.itemPrice,
    required this.warehousePrice,
    required this.newImages,
    this.qty,
  });
}

/// يفتح ديالوج تعديل كامل لبيانات العنصر
void showEditInventoryDialog(
  InventoryModel item, {
  required List<CategoryModel> categories,
  required List<ItemConditionModel> conditions,
  required Future<void> Function(EditInventoryResult result) onSave,
}) {
  Get.dialog(
    _EditInventoryDialog(
      item: item,
      categories: categories,
      conditions: conditions,
      onSave: onSave,
    ),
    barrierDismissible: false,
  );
}

class _EditInventoryDialog extends StatefulWidget {
  final InventoryModel item;
  final List<CategoryModel> categories;
  final List<ItemConditionModel> conditions;
  final Future<void> Function(EditInventoryResult result) onSave;

  const _EditInventoryDialog({
    required this.item,
    required this.categories,
    required this.conditions,
    required this.onSave,
  });

  @override
  State<_EditInventoryDialog> createState() => _EditInventoryDialogState();
}

class _EditInventoryDialogState extends State<_EditInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  late TextEditingController _itemPriceController;
  late TextEditingController _warehousePriceController;
  late TextEditingController _qtyController;

  CategoryModel? _selectedCategory;
  ItemConditionModel? _selectedCondition;

  final List<File> _newImages = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _descriptionController = TextEditingController(
      text: item.item?.description ?? "",
    );
    _detailsController = TextEditingController(
      text: item.item?.itemDetails ?? "",
    );
    _itemPriceController = TextEditingController(
      text: item.item?.basePrice?.toString() ?? "",
    );
    _warehousePriceController = TextEditingController(
      text: item.sitePrice?.toString(),
    );
    _qtyController = TextEditingController(text: item.qty?.toString());
    final currentCategoryId = item.item?.categoryId;

    if (currentCategoryId != null && widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.firstWhereOrNull(
        (c) => c.categoryId == currentCategoryId,
      );
    }

    final currentConditionId =
        item.itemCondition?.itemConditionId ?? item.itemConditionId;

    if (currentConditionId != null && widget.conditions.isNotEmpty) {
      _selectedCondition = widget.conditions.firstWhereOrNull(
        (c) => c.itemConditionId == currentConditionId,
      );
    }

    print(item.item!.toJson());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _detailsController.dispose();
    _itemPriceController.dispose();
    _qtyController.dispose();
    _warehousePriceController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _newImages.add(File(photo.path));
        });
      }
    } catch (e) {
      print(e);
      Get.snackbar("خطأ", "تعذر فتح الكاميرا");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final result = EditInventoryResult(
      category: _selectedCategory,
      condition: _selectedCondition,
      description: _descriptionController.text.trim(),
      details: _detailsController.text.trim(),
      itemPrice: double.tryParse(_itemPriceController.text.trim()) ?? 0,
      warehousePrice:
          double.tryParse(_warehousePriceController.text.trim()) ?? 0,
      newImages: _newImages,
      qty: int.tryParse(_qtyController.text.trim()) ?? 0,
    );

    await widget.onSave(result);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_rounded, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "تعديل بيانات العنصر",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSaving ? null : () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 16),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel("الفئة (Category)"),
                        DropdownButtonFormField<CategoryModel>(
                          initialValue: _selectedCategory,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            hint: "اختر الفئة",
                            icon: Icons.category_outlined,
                          ),
                          items: widget.categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name ?? "-"),
                                ),
                              )
                              .toList(),
                          onChanged: widget.categories.isEmpty || _isSaving
                              ? null
                              : (value) {
                                  setState(() => _selectedCategory = value);
                                },
                          hint: widget.categories.isEmpty
                              ? const Text(
                                  "سيتم تحميل الفئات من الـ API",
                                  style: TextStyle(fontSize: 12),
                                )
                              : null,
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel("الحالة (Condition)"),
                        DropdownButtonFormField<ItemConditionModel>(
                          initialValue: _selectedCondition,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            hint: "اختر الحالة",
                            icon: Icons.flag_outlined,
                          ),
                          items: widget.conditions
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.description ?? "-"),
                                ),
                              )
                              .toList(),
                          onChanged: widget.conditions.isEmpty || _isSaving
                              ? null
                              : (value) {
                                  setState(() => _selectedCondition = value);
                                },
                          hint: widget.conditions.isEmpty
                              ? const Text(
                                  "سيتم تحميل الحالات من الـ API",
                                  style: TextStyle(fontSize: 12),
                                )
                              : null,
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel("الوصف"),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          enabled: !_isSaving,
                          decoration: _inputDecoration(
                            hint: "اكتب وصف المنتج",
                            icon: Icons.description_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel("التفاصيل"),
                        TextFormField(
                          controller: _detailsController,
                          maxLines: 3,
                          enabled: !_isSaving,
                          decoration: _inputDecoration(
                            hint: "اكتب تفاصيل إضافية",
                            icon: Icons.list_alt_rounded,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _fieldLabel("سعر الايتم"),
                                  TextFormField(
                                    controller: _itemPriceController,
                                    enabled: !_isSaving,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: _inputDecoration(
                                      hint: "0.00",
                                      icon: Icons.sell_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _fieldLabel("سعر المخزن"),
                                  TextFormField(
                                    controller: _warehousePriceController,
                                    enabled: !_isSaving,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: _inputDecoration(
                                      hint: "0.00",
                                      icon: Icons.warehouse_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        _fieldLabel("الكمية"),
                        TextFormField(
                          controller: _qtyController,
                          enabled: !_isSaving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            hint: "0",
                            icon: Icons.production_quantity_limits,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _fieldLabel("الصور"),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ..._newImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      file,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: InkWell(
                                      onTap: _isSaving
                                          ? null
                                          : () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            InkWell(
                              onTap: _isSaving ? null : _captureImage,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("إلغاء"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GetBuilder<InventoryController>(
                        builder: (controller) => ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      controller.isUploadingImages
                                          ? "جاري رفع الصور..."
                                          : "جاري الحفظ...",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "حفظ",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }
}
