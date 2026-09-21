import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/app/Routes/app_routes.dart';
import 'package:photo_gallery/app/services/StorageService.dart';
import 'package:photo_gallery/data/local/data_base.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';
import 'package:photo_gallery/data/repository/inventory_repository.dart';
import 'package:photo_gallery/models/inventoryModel.dart';
import 'package:photo_gallery/modules/camera/views/itemdataDialog.dart';
import 'package:photo_gallery/modules/inventory/views/EditInventoryResult.dart';
import 'package:sqflite/sqflite.dart';

class InventoryController extends GetxController {
  final inventoryRepo = InventoryRepository();
  final galleryRepo = GalleryRepository();
  final StorageLocalService _storageService = Get.find<StorageLocalService>();
  bool isLoading = false;
  bool isLoadingInv = false;
  List<InventoryModel> inventoryList = [];
  List<CategoryModel> categories = [];
  List<ItemConditionModel> conditions = [];
  String? errorMessage;
  List<InventoryModel> filteredInventory = [];
  bool changeQty = false;
  //................
  CameraController? camera;
  List<PlatformModel> platforms = [];
  int? currentFolderId;
  Directory? sessionFolder;
  String ItemUpc = '';
  bool showJustForAdd = true;
  int? currentLocalFolderId;
  Database? db;
  List<Map<String, dynamic>> images = [];
  bool cameraReady = false;
  NewItemDetailsResult? newItemDetails;
  int? remoteFolderIdCreated;
  int? currentItemId;
  int? currentInvId;
  //...........

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    db = await DatabaseHelper().database;
    var businessId = _storageService.readInt('business_id');
    if (businessId != null) {
      getInventory(businessId);
      getConditions();
      getCategories(businessId);
      getPlatforms(businessId);
    }
  }

  Future<void> getInventory(int busId) async {
    isLoadingInv = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getInvByBusiness(busId);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        inventoryList = data;
        filteredInventory = List.from(data);
      },
    );

    isLoadingInv = false;
    update();
  }

  Future<void> getConditions() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getAllConditions();

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        conditions = data;
      },
    );

    isLoading = false;
    update();
  }

  Future<void> getCategories(int busId) async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getAllCategories(busId);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        categories = data;
      },
    );

    isLoading = false;
    update();
  }

  void searchInventory(String value) {
    if (value.trim().isEmpty) {
      filteredInventory = List.from(inventoryList);
    } else {
      final text = value.toLowerCase();

      filteredInventory = inventoryList.where((e) {
        return (e.productName ?? "").toLowerCase().contains(text) ||
            (e.item?.model ?? "").toLowerCase().contains(text) ||
            (e.item?.upc ?? "").toLowerCase().contains(text) ||
            (e.sku ?? "").toLowerCase().contains(text);
      }).toList();
    }

    update();
  }

  Future<void> updateInvItemQty(int inventoryId, int qty) async {
    changeQty = true;
    update();

    final result = await inventoryRepo.changeInvItemQty(inventoryId, qty);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        final index = inventoryList.indexWhere(
          (inv) => inv.inventoryId == inventoryId,
        );

        if (index != -1) {
          final updatedItem = inventoryList[index].copyWith(qty: data.qty);

          inventoryList[index] = updatedItem;

          final fIndex = filteredInventory.indexWhere(
            (inv) => inv.inventoryId == inventoryId,
          );

          if (fIndex != -1) {
            filteredInventory[fIndex] = updatedItem;
          }
        }

        update();
      },
    );

    changeQty = false;
    Get.back();
    update();
  }

  ////////////////////////////////////////////////////////////////////////
  ///
  bool isSavingItem = false;
  bool isUploadingImages = false;
  Future<void> updateInventoryItem(
    int inventoryId,
    EditInventoryResult result,
  ) async {
    isSavingItem = true;
    errorMessage = null;
    update();

    // -------- الخطوة 1: رفع الصور أولاً (لو فيه صور جديدة) --------
    List<String> uploadedImageUrls = [];

    if (result.newImages.isNotEmpty) {
      isUploadingImages = true;
      update();

      final uploadResult = await inventoryRepo.uploadInventoryImages(
        result.newImages,
      );

      isUploadingImages = false;

      bool uploadFailed = false;

      uploadResult.fold(
        (error) {
          uploadFailed = true;
          errorMessage = error.toString();
          Get.snackbar("خطأ", "تعذر رفع الصور، حاول مرة أخرى");
        },
        (urls) {
          uploadedImageUrls = urls;
        },
      );

      if (uploadFailed) {
        isSavingItem = false;
        update();
        return; // نوقف العملية لو فشل رفع الصور - ما نكمل تحديث البيانات
      }
    }

    // -------- الخطوة 2: تجهيز JSON بكل الباراميترات وإرساله --------
    final apiResult = await inventoryRepo.updateInventoryItem(
      inventoryId: inventoryId,
      categoryId: result.category?.categoryId,
      itemConditionId: result.condition?.itemConditionId,
      description: result.description,
      details: result.details,
      itemPrice: result.itemPrice,
      warehousePrice: result.warehousePrice,
      imageUrls: uploadedImageUrls,
      qty: result.qty
    );

    apiResult.fold(
      (error) {
        errorMessage = error.toString();
        Get.snackbar("خطأ", "تعذر حفظ التعديلات");
      },
      (data) {
        final index = inventoryList.indexWhere(
          (inv) => inv.inventoryId == inventoryId,
        );

        if (index != -1) {
          inventoryList[index] = data;

          final fIndex = filteredInventory.indexWhere(
            (inv) => inv.inventoryId == inventoryId,
          );

          if (fIndex != -1) {
            filteredInventory[fIndex] = data;
          }
        }

        Get.snackbar("تم", "تم تحديث بيانات العنصر بنجاح");
      },
    );

    isSavingItem = false;
    update();
  }

  /// ///////////////////
  ///
  ///
  // ================= SESSION =================
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    camera = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await camera!.initialize();
    cameraReady = true;
    update();
  }

  /// تصحيح: الدالة دي بتسيب هاردوير الكاميرا بس. قبل كده كانت بتصفّر
  /// currentFolderId كمان، ورقم المجلد ده لسه محتاجينه بعد الخروج من
  /// شاشة الكاميرا عشان نرفع الصور المجمعة لاحقًا (uploadPendingImages
  /// بتستخدمه). تصفيره الحقيقية بتحصل في endCameraSession بس.
  Future<void> disposeCamera() async {
    if (camera != null) {
      await camera!.dispose();
      camera = null;
      cameraReady = false;
    }
  }

  bool isNewlyCreatedItem = false;

  Future<int> createRemoteFolder() async {
    isLoading = true;
    update();

    // بنسجل الحالة قبل النداء: هل كان عندنا itemId جاي من نتيجة بحث UPC
    // قبل ما ننشئ الفولدر؟ لو أيوه، يبقى العنصر ده موجود مسبقًا على
    // السيرفر ومينفعش نحذفه/نحذف فولدره بعدين.
    final bool wasExistingItem = currentItemId != null;

    final result = await inventoryRepo.createServerFolder(
      addToItemAndInventory: true,
      upc: ItemUpc.isNotEmpty ? ItemUpc : null,
      itemId: currentItemId,
    );

    int folderId = result.fold(
      (error) {
        errorMessage = error.toString();
        return 0;
      },
      (data) {
        currentItemId = data['itemId'] as int?;
        return data['userFolderId'] as int;
      },
    );

    // مسموح بالحذف بس لو العنصر اتعمل جديد فعليًا في الجلسة دي (يعني
    // مكانش موجود قبل كده) ولسه المستخدم ما كملش إدخاله.
    isNewlyCreatedItem = !wasExistingItem;

    remoteFolderIdCreated = folderId;
    isLoading = false;
    update();
    return folderId;
  }

  /// تصحيح مهم: لو currentFolderId كان اتعمل مسبقًا (مثلاً من
  /// _prepareFolder على شاشة الباركود قبل ما ندخل الكاميرا أصلًا)، كان
  /// الكود القديم بيتخطى إنشاء صف "folder" المحلي بالكامل، فيفضل
  /// currentLocalFolderId = null للأبد، وبعدين takePicture كانت بتحاول
  /// تحفظ صورة بـ folder_id = null فيرمي NOT NULL constraint. دلوقتي
  /// بنفصل الاتنين: إنشاء المجلد البعيد (لو مش موجود) عن إنشاء الصف
  /// المحلي (لو مش موجود)، كل واحد على حدة.
  ///
  /// وكمان: لو الجلسة دي "استكمال" (currentLocalFolderId موجود من قبل،
  /// يعني المستخدم رجع للكاميرا عشان يضيف صور أكتر) منمسحش الصور اللي
  /// اتجمعت قبل كده.
  Future<void> startCameraSession() async {
    if (currentFolderId == null) {
      errorMessage = "لازم تعمل فولدر قبل فتح الكاميرا";
      update();
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final mainFolder = Directory('${dir.path}/ApxGallery');

    if (!await mainFolder.exists()) {
      await mainFolder.create(recursive: true);
    }

    final bool isResuming = currentLocalFolderId != null;

    if (currentLocalFolderId == null) {
      final folderName = DateTime.now()
          .toString()
          .substring(0, 19)
          .replaceAll(' ', '|');

      currentLocalFolderId = await db!.insert('folder', {
        'name': folderName,
        'business_name': _storageService.readString('business_Name') ?? '',
        'serverId': currentFolderId,
      });
    }

    sessionFolder = Directory('${mainFolder.path}/$currentFolderId');

    if (!await sessionFolder!.exists()) {
      await sessionFolder!.create(recursive: true);
    }

    if (!isResuming) {
      images.clear();
    }
    update();
  }

  Future<void> endCameraSession() async {
    await disposeCamera();

    // تصحيح: الكود القديم كان بيصفّر sessionFolder / currentFolderId
    // *قبل* ما يشيك عليهم في الـ if تحت، فالشرط كان مستحيل يتحقق (dead
    // code) والمجلد الفاضي مكانش بيتمسح أبدًا. هنا بنحفظ القيم الحقيقية
    // في متغيرات محلية الأول، وبعدين نصفّر حالة الكنترولر، وبعدين نستخدم
    // النسخة المحفوظة في عملية الحذف.
    final bool wasEmpty = images.isEmpty;
    final Directory? folderToDelete = sessionFolder;
    final int? remoteIdToDelete = remoteFolderIdCreated;
    final int? localFolderIdToDelete = currentLocalFolderId;

    sessionFolder = null;
    currentFolderId = null;
    newItemDetails = null;
    remoteFolderIdCreated = null;
    images.clear();

    if (wasEmpty && folderToDelete != null) {
      if (await folderToDelete.exists()) {
        await folderToDelete.delete(recursive: true);
      }
      if (remoteIdToDelete != null) {
        await deleteRemoteFolder(remoteIdToDelete);
      }
      if (localFolderIdToDelete != null && db != null) {
        await db!.delete(
          'folder',
          where: 'id=?',
          whereArgs: [localFolderIdToDelete],
        );
      }
    }
    update();
  }

  // ================= CAPTURE =================

  bool takingPhoto = false;

  /// تصحيح مطلوب: قبل كده كل صورة كانت بترفع فورًا للسيرفر في الخلفية.
  /// دلوقتي بنحفظها محليًا بس وبنجمّعها في `images`؛ الرفع الفعلي بيحصل
  /// دفعة واحدة لما المستخدم يدوس "حفظ المنتج" عن طريق uploadPendingImages().
  Future<void> takePicture(BuildContext context) async {
    if (!cameraReady ||
        camera == null ||
        images.length >= 10 ||
        sessionFolder == null) {
      return;
    }

    takingPhoto = true;
    update();

    try {
      final xFile = await camera!.takePicture();

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${sessionFolder!.path}/$fileName';
      final newImage = await File(xFile.path).copy(newPath);

      // بنحفظها محليًا بس، من غير أي نداء شبكة هنا.
      final id = await db!.insert('image', {
        'folder_id': currentLocalFolderId,
        'name': newImage.path,
        'server_id': 0,
        'server_addedDate': '',
        'isUploaded': 0,
      });

      images.add({'id': id, 'name': newImage.path, 'isUploaded': 0});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      takingPhoto = false;
      update();
    }
  }

  // ================= UPLOAD =================

  /// بيمسح صورة اتلقطت بس لسه ما اترفعتش (قبل ما المستخدم يدوس "حفظ
  /// المنتج") — بتمسح الملف المحلي وصفها في الداتابيز وتشيلها من القائمة.
  Future<void> removeCapturedImage(int id) async {
    final index = images.indexWhere((e) => e['id'] == id);
    if (index == -1) return;

    final path = images[index]['name'] as String;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // مش مشكلة لو الملف مش موجود أصلًا؛ المهم نشيلها من القائمة والداتابيز
    }

    await db!.delete('image', where: 'id=?', whereArgs: [id]);
    images.removeAt(index);
    update();
  }

  /// بيرفع كل الصور المحلية اللي لسه ما اتفعتش (isUploaded == 0) دفعة
  /// واحدة. بترجع true لو كل الصور اترفعت بنجاح، وbترجع false لو أي
  /// صورة فشلت (والصور اللي فشلت بتفضل isUploaded = 0 عشان تتحاول تاني).
  Future<bool> uploadPendingImages() async {
    final pending = List<Map<String, dynamic>>.from(
      images.where((img) => img['isUploaded'] == 0),
    );

    for (final img in pending) {
      final file = File(img['name'] as String);
      final uploaded = await uploadImages(file);

      if (uploaded['success'] != true) {
        return false;
      }

      await db!.update(
        'image',
        {
          'isUploaded': 1,
          'server_id': uploaded['serverImageId'],
          'server_addedDate': uploaded['insetDateInServer'],
        },
        where: 'id=?',
        whereArgs: [img['id']],
      );

      final index = images.indexWhere((e) => e['id'] == img['id']);
      if (index != -1) {
        images[index]['isUploaded'] = 1;
      }

      update();
    }

    return true;
  }

  Future<bool> finalizeAndSaveItem() async {
    final uploadedOk = await uploadPendingImages();
    if (!uploadedOk) return false;

    final itemId = currentItemId;
    if (itemId == null) {
      errorMessage = "معرف العنصر غير موجود، جرّب  مرة اخرى";
      update();
      return false;
    }

    final details = newItemDetails;
    final businessId = _storageService.readInt('business_id');

    print('========== updateItemInServer ==========');
    print('itemId: $itemId');
    print('itemDescription: ${details?.description}');
    print('itemDetails: ${details?.details}');
    print('upc: ${ItemUpc.isNotEmpty ? ItemUpc : null}');
    print('businessId: $businessId');
    print('categoryId: ${details?.category?.categoryId}');
    print('platformId: ${details?.platform?.platformId}');
    print('basePrice: ${details?.itemPrice ?? 0}');
    print('itemConditionId: ${details?.condition?.itemConditionId}');
    print('invPrice: ${details?.warehousePrice?.toString()}');
    print('qty: ${details?.qty}');
    print('========================================');

    final result = await inventoryRepo.updateItemInServer(
      itemId: itemId,
      itemDescription: details?.description,
      itemDetails: details?.details,
      upc: ItemUpc.isNotEmpty ? ItemUpc : null,
      businessId: businessId,
      categoryId: details?.category?.categoryId,
      platformId: details?.platform?.platformId,
      basePrice: details?.itemPrice ?? 0,
      itemConditionId: details?.condition?.itemConditionId,
      invPrice: details?.warehousePrice?.toString(),
      qty: details?.qty,
    );

    return result.fold(
      (error) {
        errorMessage = error;
        update();
        return false;
      },
      (data) async {
        await endCameraSession();
        return true;
      },
    );
  }

  Future<Map<String, dynamic>> uploadImages(File file) async {
    int businessId = _storageService.readInt('business_id') ?? 0;

    if (businessId == 0) {
      return {'success': false, 'serverImageId': null};
    }

    isLoading = true;
    update();

    final result = await galleryRepo.uploadImages(
      [file],
      businessId,
      currentFolderId!,
      true,
      ItemUpc,
      currentItemId!,
      itemDetails: newItemDetails,
    );

    final response = result.fold(
      (_) => {'success': false, 'serverImageId': null},
      (data) {
        return {
          'success': true,
          'serverImageId': data['remoteImageId'],
          'insetDateInServer': data['insetDate'],
        };
      },
    );

    isLoading = false;
    update();

    return response;
  }

  Future<void> deleteRemoteFolder(int id) async {
    isLoading = true;
    update();
    final result = await galleryRepo.deleteRemoteFolder(id);
    result.fold((error) => errorMessage = error.toString(), (data) {});
    isLoading = false;
    update();
  }

  bool searchingAboutItem = false;
  String searchResult = '';

  /// تصحيح: كان ناقص إرجاع searchingAboutItem لـ false وعمل update()
  /// في الآخر، فأي مؤشر تحميل مربوط بيها كان هيفضل شغال للأبد. كمان
  /// أضفت معالجة لحالة الفشل بدل ما تتجاهل بصمت.
  Future<void> searchAboutItem(String upc) async {
    searchingAboutItem = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.searchAboutItem(upc);

    result.fold(
      (error) {
        errorMessage = error.toString();
        searchResult = '';
      },
      (data) {
        searchResult = data['msg']?.toString() ?? '';
        if (searchResult.contains('item already exist in item')) {
          showJustForAdd = false;
        }

        final itemId = data['itemId'];
        final inventoryId = data['inventoryId'];

        if (itemId is int) {
          currentItemId = itemId;
        }

        if (inventoryId is int) {
          currentInvId = inventoryId;
        }
      },
    );

    searchingAboutItem = false;
    update();
  }

  bool isAddingToInventory = false;

  Future<bool> AddToinv(int itemId) async {
    isAddingToInventory = true;
    update();

    final result = await inventoryRepo.AddToInventory(itemId: itemId);

    final success = result.fold(
      (error) {
        errorMessage = error;
        Get.snackbar(
          "خطأ",
          error,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      },
      (data) {
        Get.snackbar(
          "تم",
          "تمت إضافة المنتج للمخزون بنجاح",
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      },
    );

    isAddingToInventory = false;
    update();

    return success;
  }

  Future<void> getPlatforms(int busId) async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await inventoryRepo.getAllPlatforms(busId);

    result.fold(
      (error) {
        errorMessage = error.toString();
      },
      (data) {
        platforms = data;
      },
    );

    isLoading = false;
    update();
  }
}
