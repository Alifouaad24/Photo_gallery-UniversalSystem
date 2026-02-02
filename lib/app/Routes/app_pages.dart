import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/bindings/add_item_binding.dart';
import 'package:photo_gallery/app/bindings/auth_binding.dart';
import 'package:photo_gallery/app/bindings/camera_binding.dart';
import 'package:photo_gallery/app/bindings/gallery_binding.dart';
import 'package:photo_gallery/app/bindings/home_binding.dart';
import 'package:photo_gallery/app/bindings/splash_binding.dart';
import 'package:photo_gallery/modules/add-items/views/add-itemsScreen.dart';
import 'package:photo_gallery/modules/auth/views/login_screen.dart';
import 'package:photo_gallery/modules/camera/views/camera-session.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
import 'package:photo_gallery/modules/gallery/views/fullScreenImg.dart';
import 'package:photo_gallery/modules/gallery/views/gallery-screen.dart';
import 'package:photo_gallery/modules/gallery/views/session_photos_screen.dart';
import 'package:photo_gallery/modules/home/views/home-screen.dart';
import 'package:photo_gallery/modules/splash/views/splash_screen.dart';
import 'package:photo_gallery/widgets/session_folder_item.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.cameraSession,
      page: () => CameraSessionScreen(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: Routes.gallery,
      page: () => GalleryScreen(),
      binding: GalleryBinding(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.SessionPhotosScreen,
      page: () => const SessionPhotosScreen(),
      binding: BindingsBuilder(() {
        Get.put(GalleryController());
      }),
    ),
    GetPage(
      name: Routes.FullScreenImage,
      page: () => FullScreenImageEditor(imageFile: null!),
    ),
     GetPage(
      name: Routes.addItemScreen,
      page: () => AddItemScreen(),
      binding: AddItemBinding(),
    ),
  ];
}
