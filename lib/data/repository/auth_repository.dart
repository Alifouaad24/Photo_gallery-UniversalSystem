import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/data/api/api_methods.dart';
import 'package:photo_gallery/main.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<Either<String, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/Account/Login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      return Right(data['token']);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        final errorMessage = errorData['message'] ?? 'Login failed';
        return Left(errorMessage);
      } else {
        return Left('Network error occurred');
      }
    } catch (e) {
      return Left('An unexpected error occurred');
    }
  }

  Future<Either<String, Map<String, dynamic>>> GetMyData() async {
    try {
      final response = await _dio.get(
        '/Account/GetMyData',
        options: Options(headers: {'Authorization': 'Bearer ${token}'}),
      );

      final data = response.data;
      return Right(data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return Left(data['message']?.toString() ?? 'Request failed');
      }

      if (data is String) {
        return Left(data);
      }

      return Left('Network or server error');
    }
  }
}
