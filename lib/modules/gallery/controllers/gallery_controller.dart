import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:photo_gallery/data/repository/gallery_repository.dart';

class GalleryController extends GetxController {
  final galleryRepo = GalleryRepository();
  final Set<int> selectedIndexes = {};
  bool isLoading = false;

  void toggleSelection(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
    update();
  }

  void clearSelection() {
    selectedIndexes.clear();
    update();
  }

  Future<void> uploadImages(List<File> files) async {
    isLoading = true;
    update();
    final result = await galleryRepo.uploadImages(files);
    result.fold(
      (error) {
        isLoading = false;
        update();
        Get.snackbar(
          'Error',
          error,
          backgroundColor: const Color(0xFFFF4C4C),
          colorText: Colors.white,
        );
      },
      (message) {
        isLoading = false;
        update();
        Get.snackbar(
          'Success',
          message,
          backgroundColor: const Color(0xFF4BB543),
          colorText: Colors.white,
        );
        clearSelection();
      },
    );
    isLoading = false;
    update();
  }
}
