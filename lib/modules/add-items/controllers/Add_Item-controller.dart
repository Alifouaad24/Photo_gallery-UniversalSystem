import 'package:camera/camera.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

class AddItemController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var images = <XFile>[];
  String? barcodes;
  bool scanMode = false;

  Future<void> takePhoto() async {
    scanMode = false;
    update();
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      images.add(photo);
      update();
    }
  }
  void setScanMode() {
    scanMode = true;
    update();
  }

  bool addBarcode(String code) {
    if (barcodes == null) {
      barcodes = code;
      update();
      return true;
    }
    return false;
  }

  
}
