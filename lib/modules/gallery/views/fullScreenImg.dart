import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';

class FullScreenImageEditor extends StatefulWidget {
  final File imageFile;

  const FullScreenImageEditor({super.key, required this.imageFile});

  @override
  State<FullScreenImageEditor> createState() =>
      _FullScreenImageEditorState();
}

class _FullScreenImageEditorState extends State<FullScreenImageEditor> {
  late File _currentImage;

  

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, _currentImage);
            },
          )
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
  _currentImage,
  key: ValueKey(_currentImage.path),
)
        ),
      ),
      bottomNavigationBar: _buildToolsBar(),
    );
  }

  /// شريط الأدوات
  Widget _buildToolsBar() {
  return BottomAppBar(
    color: Colors.black,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.crop, color: Colors.white),
          onPressed: _cropImage,
        ),
        IconButton(
          icon: const Icon(Icons.rotate_right, color: Colors.white),
          onPressed: _rotateImage,
        ),
        IconButton(
          icon: const Icon(Icons.filter, color: Colors.white),
          onPressed: _applyGrayFilter,
        ),
        GetBuilder<GalleryController>(builder: 
(controller) =>
        IconButton(
          icon: const Icon(Icons.qr_code, color: Colors.white),
          onPressed: () => controller.scanBarcodeFromImage(_currentImage),
        ),
        )
      ],
    ),
  );
}


Future<void> _cropImage() async {
  final cropped = await ImageCropper().cropImage(
    sourcePath: _currentImage.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
      ),
    ],
  );

  if (cropped == null) return;

  final newFile = File(
    '${_currentImage.parent.path}/crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );

  await newFile.writeAsBytes(await File(cropped.path).readAsBytes());

  setState(() {
    _currentImage = newFile;
  });
}

  /// تدوير الصورة 90 درجة
  Future<void> _rotateImage() async {
    final bytes = await _currentImage.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) return;

    final rotated = img.copyRotate(original, angle: 90);

final newPath =
    '${_currentImage.parent.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.jpg';

final newFile = File(newPath);
await newFile.writeAsBytes(img.encodeJpg(rotated));

    setState(() {
      _currentImage = newFile;
    });
  }

Future<void> _applyGrayFilter() async {
  final bytes = await _currentImage.readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null) return;

  final filtered = img.grayscale(original);

  final newPath =
      '${_currentImage.parent.path}/gray_${DateTime.now().millisecondsSinceEpoch}.jpg';

  final newFile = File(newPath);
  await newFile.writeAsBytes(img.encodeJpg(filtered));

  setState(() {
    _currentImage = newFile;
  });
}
}


