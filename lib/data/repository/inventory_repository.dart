import 'dart:io';

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
        '/Inventory/GetAllForImagerApp/${businessId}',
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
    int invId,
    int qty,
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

  Future<Either<String, List<CategoryModel>>> getAllCategories(
    int businessId,
  ) async {
    try {
      final response = await _dio.get(
        '/Category/${businessId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      var categories = (response.data as List)
          .map((el) => CategoryModel.fromJson(el))
          .toList();

      return Right(categories);
    } on DioException catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<PlatformModel>>> getAllPlatforms(
    int businessId,
  ) async {
    try {
      final response = await _dio.get(
        '/Platform/${businessId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      var platforms = (response.data as List)
          .map((el) => PlatformModel.fromJson(el))
          .toList();

      return Right(platforms);
    } on DioException catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ItemConditionModel>>> getAllConditions() async {
    try {
      final response = await _dio.get(
        '/ItemCondition',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      var categories = (response.data as List)
          .map((el) => ItemConditionModel.fromJson(el))
          .toList();

      return Right(categories);
    } on DioException catch (e) {
      return Left(e.toString());
    }
  }

  //////////////////////
  ///
  Future<Either<String, List<String>>> uploadInventoryImages(
    List<File> images,
  ) async {
    try {
      final formData = FormData();

      // ⚠️ اسم الحقل لازم يكون "Images" بالضبط عشان يطابق ImagesForm بالباك اند
      for (final file in images) {
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

      // TODO: عدّل المسار حسب الـ base URL الفعلي عندك (Controller route)
      final response = await _dio.post(
        '/api/inventory/UploadImagesToCloudinary',
        data: formData,
      );

      final urls = (response.data as List).map((e) => e.toString()).toList();

      return Right(urls);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// يحدّث بيانات العنصر (فئة، حالة، وصف، تفاصيل، سعرين، صور جديدة)
  Future<Either<String, InventoryModel>> updateInventoryItem({
    required int inventoryId,
    int? categoryId,
    int? itemConditionId,
    String? description,
    String? details,
    double? itemPrice,
    double? warehousePrice,
    List<String>? imageUrls,
    int? qty
  }) async {
    try {
      final body = {
        if (categoryId != null) 'categoryId': categoryId,
        if (itemConditionId != null) 'itemConditionId': itemConditionId,
        if (description != null) 'description': description,
        if (details != null) 'details': details,
        if(qty != null) 'qty' : qty,
        if (itemPrice != null) 'itemPrice': itemPrice,
        if (warehousePrice != null) 'warehousePrice': warehousePrice,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      };

      // TODO: عدّل المسار حسب الـ base URL والـ endpoint الفعلي عندك
      final response = await _dio.put(
        '/inventory/$inventoryId',
        data: body,
      );

      return Right(InventoryModel.fromJson(response.data));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> searchAboutItem(
    String upc,
  ) async {
    try {
      final response = await _dio.get(
        '/Item/SearchAboutItem/${upc}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      var result = response.data;

      return Right(result);
    } on DioException catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> updateItemInServer({
    required int itemId,
    String? itemDescription,
    String? itemDetails,
    String? upc,
    int? businessId,
    int? categoryId,
    int? platformId,
    int? unitId,
    double? unitValue,
    int? colorId,
    int? sizeId,
    int? currencyId,
    int? brandId,
    double? height,
    double? width,
    double? length,
    required double basePrice,
    int? itemConditionId,
    String? invPrice,
    int? qty,
  }) async {
    try {
      final response = await _dio.put(
        '/Item/$itemId',
        data: {
          'ItemDescription': itemDescription,
          'ItemDetails': itemDetails,
          'upc': upc,
          'BusinessId': businessId,
          'CategoryId': categoryId,
          'PlatformId': platformId,
          'BasePrice': basePrice,
          'ItemConditionId': itemConditionId,
          'invPrice': invPrice,
          'Qty': qty,
        },
      );

      return Right(response.data as Map<String, dynamic>);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> createServerFolder({
    required bool addToItemAndInventory,
    String? upc,
    int? itemId, // <-- جديد
  }) async {
    try {
      final response = await _dio.post(
        '/ImageUploader/CreateFolder',
        data: {
          'AddToItemAndInventory': addToItemAndInventory,
          'Upc': upc,
          'ItemId': itemId, // <-- جديد
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response.data);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Map<String, dynamic>>> AddToInventory({
    int? itemId, // <-- جديد
  }) async {
    try {
      final response = await _dio.get(
        '/Item/AddItemToInv/${itemId}',

        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Right(response.data);
    } catch (e) {
      return Left(e.toString());
    }
  }

  
}
