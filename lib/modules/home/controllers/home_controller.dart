import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeController extends GetxController {
  String version = '';
  @override
  void onInit() {
    super.onInit();
    loadVersion();
  }

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version = '${info.version} (${info.buildNumber})';
    print(version);
    update();
  }
}
