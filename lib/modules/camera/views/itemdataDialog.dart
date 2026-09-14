import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/models/inventoryModel.dart';

/// البيانات اللي ترجع بعد تعبئة بيانات المنتج الجديد
class NewItemDetailsResult {
  final CategoryModel? category;
  final PlatformModel? platform; // <-- جديد
  final ItemConditionModel? condition;
  final String description;
  final String details;
  final double? itemPrice;
  final double? warehousePrice;

  NewItemDetailsResult({
    required this.category,
    required this.platform, // <-- جديد
    required this.condition,
    required this.description,
    required this.details,
    required this.itemPrice,
    required this.warehousePrice,
  });
}

/// يفتح ديالوج تعبئة بيانات منتج جديد (يُستخدم بشاشة الكاميرا وقت
/// AddToItemAndInventory = true). ما فيه التقاط صور هنا لأن الصور
/// نفسها تُلتقط أصلاً من شاشة الكاميرا.
void showAddItemDetailsDialog({
  required List<CategoryModel> categories,
  required List<ItemConditionModel> conditions,
  required List<PlatformModel> platforms,
  NewItemDetailsResult? initialValue,
  required void Function(NewItemDetailsResult result) onSave,
}) {
  Get.dialog(
    _AddItemDetailsDialog(
      categories: categories,
      conditions: conditions,
      platforms: platforms,
      initialValue: initialValue,
      onSave: onSave,
    ),
    barrierDismissible: false,
  );
}

class _AddItemDetailsDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<PlatformModel> platforms; // <-- جديد
  final List<ItemConditionModel> conditions;
  final NewItemDetailsResult? initialValue;
  final void Function(NewItemDetailsResult result) onSave;

  const _AddItemDetailsDialog({
    required this.categories,
    required this.platforms, // <-- جديد
    required this.conditions,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_AddItemDetailsDialog> createState() => _AddItemDetailsDialogState();
}

class _AddItemDetailsDialogState extends State<_AddItemDetailsDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  late TextEditingController _itemPriceController;
  late TextEditingController _warehousePriceController;

  CategoryModel? _selectedCategory;
  ItemConditionModel? _selectedCondition;
  PlatformModel? _selectedPlatform;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialValue;

    _descriptionController =
        TextEditingController(text: initial?.description ?? "");
    _detailsController = TextEditingController(text: initial?.details ?? "");
    _itemPriceController = TextEditingController(
      text: initial?.itemPrice?.toString() ?? "",
    );
    _warehousePriceController = TextEditingController(
      text: initial?.warehousePrice?.toString() ?? "",
    );

    _selectedCategory = initial?.category;
    _selectedCondition = initial?.condition;
    _selectedPlatform = initial?.platform;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _detailsController.dispose();
    _itemPriceController.dispose();
    _warehousePriceController.dispose();
    super.dispose();
  }

  void _handleSave() {
  if (!_formKey.currentState!.validate()) return;

  final result = NewItemDetailsResult(
    category: _selectedCategory,
    platform: _selectedPlatform, // <-- جديد
    condition: _selectedCondition,
    description: _descriptionController.text.trim(),
    details: _detailsController.text.trim(),
    itemPrice: double.tryParse(_itemPriceController.text.trim()),
    warehousePrice: double.tryParse(_warehousePriceController.text.trim()),
  );

  widget.onSave(result);
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
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------- Header --------
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "بيانات المنتج الجديد",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
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
                        /// -------- Category dropdown --------
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
                          onChanged: widget.categories.isEmpty
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
                          validator: (value) =>
                              value == null ? "اختر الفئة" : null,
                        ),

                        const SizedBox(height: 16),
                        const SizedBox(height: 16),

/// -------- Platform dropdown --------
_fieldLabel("المنصة (Platform)"),
DropdownButtonFormField<PlatformModel>(
  initialValue: _selectedPlatform,
  isExpanded: true,
  decoration: _inputDecoration(
    hint: "اختر المنصة",
    icon: Icons.storefront_outlined,
  ),
  items: widget.platforms
      .map(
        (p) => DropdownMenuItem(
          value: p,
          child: Text(p.description ?? "-"),
        ),
      )
      .toList(),
  onChanged: widget.platforms.isEmpty
      ? null
      : (value) {
          setState(() => _selectedPlatform = value);
        },
  hint: widget.platforms.isEmpty
      ? const Text(
          "سيتم تحميل المنصات من الـ API",
          style: TextStyle(fontSize: 12),
        )
      : null,
),

                        /// -------- Condition dropdown --------
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
                          onChanged: widget.conditions.isEmpty
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
                          validator: (value) =>
                              value == null ? "اختر الحالة" : null,
                        ),

                        const SizedBox(height: 16),

                        /// -------- Description --------
                        _fieldLabel("الوصف"),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            hint: "اكتب وصف المنتج",
                            icon: Icons.description_outlined,
                          ),
                          validator: (value) => (value == null ||
                                  value.trim().isEmpty)
                              ? "أدخل الوصف"
                              : null,
                        ),

                        const SizedBox(height: 16),

                        /// -------- Details --------
                        _fieldLabel("التفاصيل"),
                        TextFormField(
                          controller: _detailsController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            hint: "اكتب تفاصيل إضافية",
                            icon: Icons.list_alt_rounded,
                          ),
                          validator: (value) => (value == null ||
                                  value.trim().isEmpty)
                              ? "أدخل التفاصيل"
                              : null,
                        ),

                        const SizedBox(height: 16),

                        /// -------- Item price + Warehouse price --------
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _fieldLabel("سعر الايتم"),
                                  TextFormField(
                                    controller: _itemPriceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: "0.00",
                                      icon: Icons.sell_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "أدخل السعر";
                                      }
                                      if (double.tryParse(value.trim()) ==
                                          null) {
                                        return "رقم غير صحيح";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _fieldLabel("سعر المخزن"),
                                  TextFormField(
                                    controller: _warehousePriceController,
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// -------- Actions --------
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "حفظ",
                          style: TextStyle(color: Colors.white),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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