import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_gallery/data/api/api_methods.dart';
import 'package:photo_gallery/main.dart';

class GalleryRepository {
  Dio _dio = DioClient().dio;

  Future<Either<String, Map<String, dynamic>>> uploadImages(
    List<File> files,
    int businessId,
    int folderId,
    bool AddToItemAndInventory,
    String ItemUpc,
  ) async {
    try {
      final formData = FormData();

      for (final file in files) {
        formData.files.add(
          MapEntry(
            'Images',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      formData.fields.add(MapEntry('BusinessId', businessId.toString()));
      formData.fields.add(MapEntry('FolderId', folderId.toString()));
      formData.fields.add(
        MapEntry('AddToItemAndInventory', AddToItemAndInventory.toString()),
      );
      formData.fields.add(MapEntry('upc', ItemUpc));
      // 🖨️ Print FormData fields
      print('========== FORM DATA ==========');

      for (final field in formData.fields) {
        print('${field.key}: ${field.value}');
      }

      // 🖼️ Print uploaded files
      print('---------- FILES ----------');

      for (final file in formData.files) {
        print('Key: ${file.key}');
        print('Filename: ${file.value.filename}');
        print('Content-Type: ${file.value.contentType}');
        print('Length: ${file.value.length}');
      }
      final response = await _dio.post(
        '/ImageUploader',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data ?? {'message': 'خطأ في رفع الصور'});
    }
  }

  Future<Either<String, Map<String, dynamic>>> createServerFolder({
  required bool addToItemAndInventory,
  String? upc,
}) async {
  try {
    final response = await _dio.post(
      '/ImageUploader/CreateFolder',
      data: {
        'AddToItemAndInventory': addToItemAndInventory,
        'Upc': upc,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Right(response.data);
  } catch (e) {
    return Left(e.toString());
  }
}

  Future<Either<String, Map<String, dynamic>>> deleteRemoteFolder(
    int id,
  ) async {
    try {
      final response = await _dio.delete(
        '/ImageUploader/DeleteFolder/${id}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(e.response?.data ?? {'message': 'خطأ في حذف المجلد'});
    }
  }
}
