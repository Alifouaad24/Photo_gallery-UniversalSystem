import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:photo_gallery/modules/add-items/controllers/Add_Item-controller.dart';
import 'package:photo_gallery/modules/add-items/widgets/camera_and_barcode_scanner_screen.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddItemController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Add Item')),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const CameraScreen());
                    },
                    child: const Text('Camera / Barcode'),
                  ),
                ),

                const SizedBox(height: 16),
                if (controller.images.isNotEmpty)
                Text(
                  'Images:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.images.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.images.map((img) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.file(
                            File(img.path),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 18),
                // Barcode below images
                if (controller.barcodes != null && controller.images.isNotEmpty)
                Divider(),
                if (controller.barcodes != null)
                  Text(
                    'SKU: ${controller.barcodes}' ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed:
                        (controller.images.isEmpty && controller.barcodes == null)
                        ? null
                        : () {},
                    child: const Text('Save Item'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
