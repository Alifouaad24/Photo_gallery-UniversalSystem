import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/modules/gallery/controllers/gallery_controller.dart';

class CameraSessionScreen extends StatefulWidget {
  const CameraSessionScreen({super.key});

  @override
  State<CameraSessionScreen> createState() => _CameraSessionScreenState();
}

class _CameraSessionScreenState extends State<CameraSessionScreen> {
  GalleryController? galleryController = Get.put(GalleryController());
  CameraController? _controller;
  final List<File> capturedImages = [];
  late Directory sessionDir;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _createSessionFolder();
    await _initCamera();
    setState(() => ready = true);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> _createSessionFolder() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final folderName = DateTime.now().millisecondsSinceEpoch.toString();
    sessionDir = Directory('${baseDir.path}/sessions/$folderName');
    await sessionDir.create(recursive: true);
  }

  Future<void> capture() async {
    List<File> tempList = <File>[];
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        capturedImages.length >= 10)
      return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
    final xFile = await _controller!.takePicture();
    final newPath = '${sessionDir.path}/img_${capturedImages.length}.jpg';

    final saved = await File(xFile.path).copy(newPath);
    tempList.add(saved);
    _showFlash();
    setState(() => capturedImages.add(saved));
    await galleryController?.uploadImages(tempList);
    tempList.clear();
  }

  void _showFlash() {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(color: Colors.white.withOpacity(0.7)),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 100), () {
      entry.remove();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ready || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                '${capturedImages.length}/10',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // زر التصوير
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: capture,
                child: const Icon(Icons.camera),
              ),
            ),
          ),

          // زر الرجوع
          Positioned(
            bottom: 40,
            left: 20,
            child: IconButton(
              color: const Color.fromARGB(255, 91, 198, 41),
              iconSize: 40,
              icon: const Icon(Icons.save),
              onPressed: () {
                Navigator.pop(context, capturedImages.isNotEmpty);
              },
            ),
          ),
        ],
      ),
    );
  }
}
