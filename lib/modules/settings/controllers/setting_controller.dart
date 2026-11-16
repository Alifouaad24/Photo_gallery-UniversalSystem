import 'package:get/get.dart';
import 'package:photo_gallery/app/services/StorageService.dart';

class SettingsController extends GetxController {
  final StorageLocalService storageService = Get.find<StorageLocalService>();

  // القيمة الحالية لمفتاح المنتج (upc أو sku)
  String productKey = '';

  @override
  void onInit() {
    super.onInit();
    // قراءة القيمة المحفوظة عند فتح الشاشة
    productKey = storageService.readString('product_key') ?? '';
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
}