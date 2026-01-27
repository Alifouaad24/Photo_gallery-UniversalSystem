import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/data/api/api_methods.dart';
import 'package:photo_gallery/main.dart';
import 'package:photo_gallery/models/splashResponseModel.dart';
import 'package:photo_gallery/modules/auth/LoginResponse.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<Either<String, LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/Account/Login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final loginResponse = LoginResponse.fromJson(data);
      return Right(loginResponse);
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

  Future<Either<String, UserResponse>> GetMyData() async {
    try {
      final response = await _dio.get(
        '/Account/GetMyData',
        options: Options(headers: {'Authorization': 'Bearer ${token}'}),
      );

      final data = response.data;
      final userResponse = UserResponse.fromJson(data);
      return Right(userResponse);
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
