import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photo_gallery/data/api/api_methods.dart';
import 'package:photo_gallery/main.dart';
import 'package:photo_gallery/models/inventoryModel.dart';

class InventoryRepository {
  Dio _dio = DioClient().dio;

  Future<Either<String, List<InventoryModel>>> getInvByBusiness(
    int businessId,
  ) async {
    try {
      final response = await _dio.get(
        '/Inventory/${businessId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      var listInv = (response.data as List)
          .map((e) => InventoryModel.fromJson(e))
          .toList();
          
      return Right(listInv);
    } on DioException catch (e) {
      return Left(e.toString());
    }
  }


   Future<Either<String, InventoryModel>> changeInvItemQty(
    int invId, int qty
  ) async {
    try {
      final response = await _dio.put(
        '/Inventory/ChangeQty/${invId}/${qty}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      var Inv = InventoryModel.fromJson(response.data);
          
      return Right(Inv);

    } on DioException catch (e) {
      return Left(e.toString());
    }
  }
}
