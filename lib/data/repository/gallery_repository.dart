import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photo_gallery/data/api/api_methods.dart';
import 'package:photo_gallery/main.dart';

class GalleryRepository {
  Dio _dio = DioClient().dio;

  Future<Either<String, String>> uploadImages(List<File> files, int businessId) async {
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

      final response = await _dio.post(
        '/ImageUploader',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Right(response.data['message']);
    } on DioException catch (e) {
      return Left(e.response?.data?.toString() ?? 'خطأ في رفع الصور');
    }
  }
}
