import 'package:get/get.dart';
import 'package:photo_gallery/app/services/StorageService.dart';

class SettingsController extends GetxController {
  final StorageLocalService storageService = Get.find<StorageLocalService>();

  // مفاتيح التخزين لإظهار/إخفاء حقول بيانات المنتج
  static const String showSizeKey = 'show_size';
  static const String showConditionKey = 'show_condition';

  /// قراءة الإعدادات من أي مكان (ديالوجات الإضافة والتعديل) بدون
  /// الحاجة لعمل Get.put للكنترولر.
  /// Condition افتراضيًا ظاهر (نفس السلوك القديم)، Size افتراضيًا مخفي.
  static bool get isSizeEnabled =>
      Get.find<StorageLocalService>().readBool(showSizeKey) ?? false;
  static bool get isConditionEnabled =>
      Get.find<StorageLocalService>().readBool(showConditionKey) ?? true;

  // القيمة الحالية لمفتاح المنتج (upc أو sku)
  String productKey = '';
  bool showSize = false;
  bool showCondition = true;

  @override
  void onInit() {
    super.onInit();
    // قراءة القيمة المحفوظة عند فتح الشاشة
    productKey = storageService.readString('product_key') ?? '';
    showSize = isSizeEnabled;
    showCondition = isConditionEnabled;
    update();
  }

  // تغيير نوع مفتاح المنتج
  void setProductKey(String value) {
    productKey = value;
    storageService.writeString('product_key', value);
    update();
    Get.snackbar(
      'تم الحفظ',
      'نوع مفتاح المنتج: ${value.toUpperCase()}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // إظهار/إخفاء حقل Size
  void setShowSize(bool value) {
    showSize = value;
    storageService.writeBool(showSizeKey, value);
    update();
  }

  // إظهار/إخفاء حقل Condition
  void setShowCondition(bool value) {
    showCondition = value;
    storageService.writeBool(showConditionKey, value);
    update();
  }
}
