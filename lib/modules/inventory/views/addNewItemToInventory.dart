import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/modules/camera/views/itemdataDialog.dart';
import 'package:photo_gallery/modules/inventory/controllers/inventory_controller.dart';
import 'package:photo_gallery/modules/inventory/views/addUpcToItem.dart';

// ملحوظة: استيراد addUpcToItem.dart وcamera_controller.dart كانوا مش
// مستخدمين في أي مكان بالكود، فشلتهم عشان يمنعوا تحذير "unused_import".
// بيانات المنتج (categories/conditions/platforms) بقت بتتاخد من نفس
// InventoryController، فمش محتاجين CameraGetController خالص هنا.

/// -------- Design tokens --------
class _Palette {
  static const bg = Color(0xFFF4F6F9);
  static const card = Colors.white;
  static const border = Color(0xFFEDEFF3);
  static const ink = Color(0xFF1B1F27);
  static const inkMuted = Color(0xFF6B7280);
  static const primary = Color(0xFF3457D5);
  static const primarySoft = Color(0xFFEFF2FF);
  static const disabled = Color(0xFFD8DBE2);
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFE9F9EF);
}

class Addnewitemtoinventory extends StatefulWidget {
  const Addnewitemtoinventory({super.key});

  @override
  State<Addnewitemtoinventory> createState() => _AddnewitemtoinventoryState();
}

class _AddnewitemtoinventoryState extends State<Addnewitemtoinventory> {
  late final InventoryController cameraController;

  /// الباركود اللي اتقرأ من الكاميرا (أو اتكتب يدويًا). لو فاضي = زرار الكاميرا معطل.
  String _barcode = '';
  bool _isPreparing = false;
  bool _isSearching = false;
  final TextEditingController _barcodeController = TextEditingController();

  /// true لو المستخدم رجع من شاشة الكاميرا وفيه صور اتلقطت فعلًا —
  /// وقتها بيظهر زرار "حفظ المنتج".
  bool _hasCapturedImages = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // initState لازم تكون sync دايمًا، فبننادي دالة async منفصلة بدل
    // ما نحط await جوه initState نفسها (ده كان بيرمي خطأ compile).
    cameraController = Get.find<InventoryController>();
    // _prepareFolder();
  }

  Future<void> _prepareFolder() async {
    cameraController.ItemUpc = '';
    try {
      cameraController.currentFolderId = await cameraController
          .createRemoteFolder();
    } catch (e) {
      // لو فشل إنشاء المجلد، منسيبش المستخدم واقف من غير رد فعل
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر تجهيز الجلسة، حاول مرة أخرى")),
        );
      }
    } finally {
      if (mounted) setState(() => _isPreparing = false);
    }
  }

  @override
  void dispose() {
    if (cameraController.images.isEmpty &&
        cameraController.currentFolderId != null &&
        cameraController.isNewlyCreatedItem) {
      // <-- الشرط الجديد
      cameraController.deleteRemoteFolder(cameraController.currentFolderId!);
    }
    _barcodeController.dispose();
    super.dispose();
  }

  bool get _hasBarcode => _barcode.isNotEmpty;

  Future<void> _openBarcodeScanner() async {
    final result = await Get.to<String>(() => const BarcodeScannerScreen());
    if (result == null || result.isEmpty) return;

    _applyBarcode(result);
    // لما الكاميرا تنجح في القراءة، ندور على المنتج أوتوماتيك.
    _searchForItem();
  }

  /// بتتنادى سواء من نتيجة الكاميرا أو من كتابة المستخدم اليدوية.
  /// دي بقت sync عادية (من غير async) لأنها بقت مش بتعمل أي نداء شبكة
  /// بنفسها؛ البحث الفعلي بقى في دالة منفصلة _searchForItem تحت.
  void _applyBarcode(String value) {
    final trimmed = value.trim();

    if (trimmed != _barcode &&
        cameraController.currentFolderId != null &&
        cameraController.images.isEmpty &&
        cameraController.isNewlyCreatedItem) {
      // <-- الشرط الجديد
      cameraController.deleteRemoteFolder(cameraController.currentFolderId!);
      cameraController.currentFolderId = null;
      cameraController.currentItemId = null;
      cameraController.isNewlyCreatedItem = false;
    }
    setState(() => _barcode = trimmed);

    // بنحدث النص في الحقل بس من غير ما نعمل loop لا نهائي مع onChanged
    if (_barcodeController.text != trimmed) {
      _barcodeController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }

    cameraController.ItemUpc = trimmed;
    cameraController.update();
  }

  Future<void> _ensureFolder() async {
    if (cameraController.currentFolderId != null) return; // اتعمل من قبل

    setState(() => _isPreparing = true);
    try {
      cameraController.currentFolderId = await cameraController
          .createRemoteFolder();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر تجهيز الجلسة، حاول مرة أخرى")),
        );
      }
    } finally {
      if (mounted) setState(() => _isPreparing = false);
    }
  }

  /// الدالة اللي فعليًا بتبحث عن المنتج بالباركود.
  ///
  /// تصحيح مهم: اسم الدالة الحقيقي في الكنترولر هو `searchAboutItem`
  /// (من غير "ing") وبياخد `String`. الكود القديم كان بينادي على
  /// `searchingAboutItem` وده أصلًا متغير `bool` مش دالة، فمكانش هيعمل
  /// compile خالص. كمان كان بيتبعت له `_barcodeController.value` اللي
  /// نوعه `TextEditingValue` مش `String`.
  Future<void> _searchForItem() async {
    if (_barcode.isEmpty || _isSearching) return;

    setState(() => _isSearching = true);

    await cameraController.searchAboutItem(_barcode);

    if (!mounted) return;
    setState(() => _isSearching = false);

    final message = cameraController.errorMessage;
    final result = cameraController.searchResult;

    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } else if (result.isNotEmpty) {
      _showSearchResultDialog(result);
    }

    await _ensureFolder();
  }

  /// بوب أب بسيط بيعرض نتيجة البحث (searchResult) مع زرين تحت.
  /// الزرين دلوقتي مش متبرمجين — بس بيقفلوا البوب أب. لما يتحدد المطلوب
  /// منهم بالظبط (مثلاً: "استخدام المنتج" / "منتج جديد") نحط المنطق
  /// جوه الـ onPressed بتاعهم مكان الـ TODO.
  void _showSearchResultDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _Palette.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _Palette.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: _Palette.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "نتيجة البحث عن المنتج",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _Palette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _Palette.inkMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: منطق الزرار الثاني لسه مش متحدد (مثلاً: تجاهل النتيجة / إضافة كمنتج جديد)
                          Navigator.of(ctx).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _Palette.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: _Palette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (message.contains('item already exist in item'))
                      Expanded(
                        child: GetBuilder<InventoryController>(
                          builder: (controller) => ElevatedButton(
                            onPressed: controller.isAddingToInventory
                                ? null // معطل أثناء التنفيذ عشان يمنع دوس مزدوج
                                : () async {
                                    final itemId = controller.currentItemId;
                                    if (itemId == null) return;

                                    final ok = await controller.AddToinv(
                                      itemId,
                                    );

                                    if (!ok) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            controller.errorMessage ??
                                                "تعذر إضافة المنتج",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.of(ctx).pop(); // قفل البوب أب
                                    Get.offAllNamed(
                                      Routes.home,
                                    ); // رجوع للرئيسية
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Palette.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isAddingToInventory
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Add to inventory",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// نُقلت من شاشة الكاميرا (Addimagestoitem) لهنا بناءً على طلبك، عشان
  /// المستخدم يعبي بيانات المنتج (فئة/حالة/منصة...) قبل ما يدخل الكاميرا
  /// أصلًا. البيانات بتتاخد من InventoryController نفسه (نفس الكنترولر
  /// اللي عندنا هنا)، فمش محتاجين نجيب أي كنترولر تاني.
  void _openItemDetailsDialog() {
    showAddItemDetailsDialog(
      categories: cameraController.categories,
      platforms: cameraController.platforms,
      conditions: cameraController.conditions,
      initialValue: cameraController.newItemDetails,
      onSave: (result) {
        setState(() {
          cameraController.newItemDetails = result;
        });
        cameraController.update();
      },
    );
  }

  Future<void> _openCamera() async {
    if (!_hasBarcode) return; // حماية إضافية، الزرار أصلًا معطل بصريًا
    await _ensureFolder();
    cameraController.ItemUpc = _barcode;
    cameraController.update();

    await Get.toNamed(Routes.invCamera);

    // تصحيح/تعديل مطلوب: قبل كده كنا بنروح مباشرة لشاشة الـ gallery بعد
    // الرجوع من الكاميرا. دلوقتي المفروض نفضل في نفس الشاشة ونشوف هل
    // المستخدم لقط صور فعلًا (images بقت مجمعة، مش مرفوعة بعد)، ولو
    // أيوه نظهر زرار "حفظ المنتج" بدل ما نتنقل تلقائي.
    if (mounted) {
      setState(() {
        _hasCapturedImages = cameraController.images.isNotEmpty;
      });
    }
  }

  /// زرار "حفظ المنتج": بيرفع كل الصور المجمعة دفعة واحدة (batch) وبعدين
  /// المفروض يحفظ عنصر المخزون فعليًا (لسه TODO جوه finalizeAndSaveItem
  /// في الكنترولر لحد ما توضح شكل الـ API بتاع الإنشاء).
  Future<void> _saveProduct() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final ok = await cameraController.finalizeAndSaveItem();

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Get.offAllNamed(Routes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تعذر رفع كل الصور، حاول مرة أخرى")),
      );
    }
  }

  /// بتتنادى من زرار الحذف على أي صورة في معرض الصور الملتقطة.
  Future<void> _removePhoto(int id) async {
    await cameraController.removeCapturedImage(id);
    if (!mounted) return;
    setState(() {
      _hasCapturedImages = cameraController.images.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      appBar: AppBar(
        backgroundColor: _Palette.card,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.08),
        foregroundColor: _Palette.ink,
        centerTitle: false,
        title: const Text(
          "إضافة منتج جديد",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// -------- Illustration / icon circle (تدرج لوني + ظل) --------
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_Palette.primary, Color(0xFF6E8CFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.primary.withOpacity(0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "أضف منتجًا جديدًا للمخزون",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _Palette.ink,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "اتبع الخطوات لإضافة المنتج للمخزون",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: _Palette.inkMuted),
                ),

                const SizedBox(height: 30),

                /// -------- الخطوة 1: الباركود (مسح أو إدخال يدوي) --------
                _BarcodeInputCard(
                  controller: _barcodeController,
                  isDone: _hasBarcode,
                  isSearching: _isSearching,
                  onScanTap: _openBarcodeScanner,
                  onSearchTap: _searchForItem,
                  onChanged: _applyBarcode,
                ),
                if (cameraController.showJustForAdd) const SizedBox(height: 5),
                if (cameraController.showJustForAdd)
                  /// --if (cameraController.showJustForAdd)------ خط واصل: بيتلون أخضر لو الخطوة اللي قبله خلصت --------
                  _StepConnector(active: _hasBarcode),

                const SizedBox(height: 5),

                /// -------- الخطوة 2: بيانات المنتج (نُقلت من شاشة الكاميرا) --------
                if (cameraController.showJustForAdd)
                  _StepCard(
                    stepNumber: 2,
                    title: "بيانات المنتج",
                    subtitle: cameraController.newItemDetails != null
                        ? "تم تعبئة البيانات، اضغط للتعديل"
                        : "الفئة، الحالة، المنصة وتفاصيل تانية (اختياري)",
                    icon: Icons.inventory_2_outlined,
                    onTap: _openItemDetailsDialog,
                    isDone: cameraController.newItemDetails != null,
                  ),
                if (cameraController.showJustForAdd) const SizedBox(height: 12),
                if (cameraController.showJustForAdd)
                  /// -------- خط واصل --------
                  _StepConnector(
                    active: cameraController.newItemDetails != null,
                  ),
                if (cameraController.showJustForAdd) const SizedBox(height: 5),
                if (cameraController.showJustForAdd)
                  /// -------- الخطوة 3: تصوير المنتج --------
                  _StepCard(
                    stepNumber: 3,
                    title: "صوّر المنتج",
                    subtitle: _hasCapturedImages
                        ? "${cameraController.images.length} صورة جاهزة — اضغط لإضافة المزيد"
                        : (_hasBarcode
                              ? "اضغط لفتح الكاميرا وتصوير المنتج"
                              : "امسح الباركود أولًا لتفعيل هذه الخطوة"),
                    icon: Icons.camera_alt_rounded,
                    onTap: _openCamera,
                    enabled: _hasBarcode,
                    isDone: _hasCapturedImages,
                  ),
                if (cameraController.showJustForAdd)
                  /// -------- معرض الصور الملتقطة --------
                  if (_hasCapturedImages) ...[
                    const SizedBox(height: 16),
                    _CapturedPhotosGallery(
                      images: cameraController.images,
                      onAddMore: _openCamera,
                      onRemove: _removePhoto,
                    ),
                  ],
                if (cameraController.showJustForAdd)
                  /// -------- زرار حفظ المنتج: بيظهر بس بعد ما يتلقط صورة واحدة على الأقل --------
                  if (_hasCapturedImages) ...[
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Palette.primary,
                          disabledBackgroundColor: _Palette.primary.withOpacity(
                            0.6,
                          ),
                          elevation: 0,
                          shadowColor: _Palette.primary.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "حفظ المنتج",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.5,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],

                if (_isPreparing) ...[
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// -------- كارت الخطوة الأولى: مسح الباركود بالكاميرا أو كتابته يدويًا --------
/// بيتعامل مع حالتين:
/// 1) الكاميرا نجحت في القراءة -> القيمة بتتعبى تلقائيًا في الحقل وبيتم
///    البحث عن المنتج أوتوماتيك.
/// 2) الكاميرا فشلت (إضاءة ضعيفة، باركود تالف...) -> المستخدم يكتب
///    الباركود بنفسه في نفس الحقل، وبيدوس على زرار البحث يدويًا.
class _BarcodeInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isDone;
  final bool isSearching;
  final VoidCallback onScanTap;
  final VoidCallback onSearchTap;
  final ValueChanged<String> onChanged;

  const _BarcodeInputCard({
    required this.controller,
    required this.isDone,
    required this.isSearching,
    required this.onScanTap,
    required this.onSearchTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isDone ? _Palette.success : _Palette.primary;
    final Color accentSoft = isDone
        ? _Palette.successSoft
        : _Palette.primarySoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// -------- رأس الكارت: رقم الخطوة + العنوان + زرار الكاميرا --------
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.barcode_reader,
                  color: accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "1",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "باركود المنتج",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _Palette.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDone
                          ? "تم رصد الباركود بنجاح"
                          : "امسحه بالكاميرا أو اكتبه يدويًا",
                      style: const TextStyle(
                        fontSize: 12,
                        color: _Palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),

              /// زرار فتح الكاميرا لقراءة الباركود
              InkWell(
                onTap: onScanTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _Palette.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// -------- حقل الإدخال: بيعرض القيمة اللي اتقرأت، وبيقبل الكتابة اليدوية --------
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _Palette.ink,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "لم يتم التقاط الباركود؟ اكتبه هنا يدويًا",
                    hintStyle: const TextStyle(
                      fontSize: 12.5,
                      color: _Palette.inkMuted,
                    ),
                    filled: true,
                    fillColor: isDone ? _Palette.successSoft : _Palette.bg,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDone ? _Palette.success : _Palette.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _Palette.primary,
                        width: 1.4,
                      ),
                    ),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: _Palette.inkMuted,
                            ),
                            onPressed: () {
                              var invController =
                                  Get.find<InventoryController>();
                              invController.showJustForAdd = true;
                              invController.update();
                              controller.clear();
                              onChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// زرار البحث عن المنتج بالباركود المكتوب/المقروء حاليًا.
              /// معطل تلقائيًا لو مفيش باركود أو لو في بحث شغال بالفعل.
              InkWell(
                onTap: (isDone && !isSearching) ? onSearchTap : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDone && !isSearching)
                        ? _Palette.primary
                        : _Palette.disabled,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// -------- كارت خطوة قابل لإعادة الاستخدام (مفعل / معطل / منجز) --------
class _StepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool isDone;

  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = isDone
        ? _Palette.success
        : (enabled ? _Palette.primary : _Palette.disabled);
    final Color accentSoft = isDone
        ? _Palette.successSoft
        : (enabled ? _Palette.primarySoft : _Palette.bg);

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: IgnorePointer(
        ignoring: !enabled,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _Palette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _Palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : icon,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$stepNumber",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _Palette.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _Palette.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: enabled ? _Palette.inkMuted : _Palette.disabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// -------- خط ربط بين خطوتين: بيتلون أخضر لو الخطوة اللي قبله "منجزة" --------
class _StepConnector extends StatelessWidget {
  final bool active;

  const _StepConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 25), // نفس نص عرض دائرة الأيقونة (52/2) تقريبًا
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 3,
          height: 24,
          decoration: BoxDecoration(
            color: active ? _Palette.success : _Palette.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// -------- معرض الصور الملتقطة: عرض/حذف الصور قبل الحفظ + زرار "إضافة المزيد" --------
class _CapturedPhotosGallery extends StatelessWidget {
  final List<Map<String, dynamic>> images;
  final VoidCallback onAddMore;
  final ValueChanged<int> onRemove;

  const _CapturedPhotosGallery({
    required this.images,
    required this.onAddMore,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAddMore = images.length < 10;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_rounded,
                size: 18,
                color: _Palette.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "الصور الملتقطة (${images.length}/10)",
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _Palette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final img in images)
                _PhotoThumb(
                  path: img['name'] as String,
                  isUploaded: img['isUploaded'] == 1,
                  onRemove: () => onRemove(img['id'] as int),
                ),
              if (canAddMore) _AddMoreTile(onTap: onAddMore),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final bool isUploaded;
  final VoidCallback onRemove;

  const _PhotoThumb({
    required this.path,
    required this.isUploaded,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(path),
            width: 78,
            height: 78,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 78,
              height: 78,
              color: _Palette.bg,
              child: const Icon(
                Icons.broken_image_rounded,
                color: _Palette.inkMuted,
                size: 22,
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddMoreTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMoreTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: _Palette.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _Palette.primary.withOpacity(0.35),
            width: 1.4,
          ),
        ),
        child: const Icon(Icons.add_rounded, color: _Palette.primary, size: 26),
      ),
    );
  }
}
