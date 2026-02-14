// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:get/get_connect/http/src/multipart/form_data.dart';
// import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
// import 'package:photo_gallery/data/local/data_base.dart';
// import 'package:photo_gallery/main.dart';
// import 'package:photo_gallery/models/folderModel.dart';
// import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';
// import 'package:workmanager/workmanager.dart';

// class Backgrounduploader {
//   GalleryController gallCont = GalleryController();
//   List<File>? listFiles;
//   Future<bool> isConnected() async {
//     var result = await Connectivity().checkConnectivity();
//     return result != ConnectivityResult.none;
//   }

//   void callbackDispatcher() {
//     Workmanager().executeTask((task, inputData) async {
//       print("Background task executed: $task");

//       var connectivity = await Connectivity().checkConnectivity();
//       if (connectivity == ConnectivityResult.none) {
//         print("No internet connection, skipping upload.");
//         return Future.value(false);
//       }

//       final database = await DatabaseHelper().database;
//       final imagesJson = await database.query(
//         'images',
//         where: 'isUploaded = ?',
//         whereArgs: [0],
//       );
//       final images = imagesJson.map((e) => ImageItem.fromMap(e)).toList();

//       List<File> filesToUpload = [];
//       for (var img in images) {
//         final file = File(img.name);
//         if (await file.exists()) {
//           filesToUpload.add(file);
//         }
//       }

//       try {
//         final formData = FormData();

//         for (final file in filesToUpload) {
//           formData.files.add(
//             MapEntry(
//               'Images',
//               await MultipartFile.fromFile(
//                 file.path,
//                 filename: file.path.split('/').last,
//               ),
//             ),
//           );
//         }

//         formData.fields.add(MapEntry('BusinessId', businessId.toString()));

//         final response = await _dio.post(
//           '/ImageUploader',
//           data: formData,
//           options: Options(headers: {'Authorization': 'Bearer $token'}),
//         );
//       } on DioException catch (e) {}

//       return Future.value(true);
//     });
//   }
// }
