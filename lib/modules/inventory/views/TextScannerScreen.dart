import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

/// شاشة قراءة نص (SKU) بالكاميرا.
/// مأخوذة من شاشة قراءة الـ VIN بالتطبيق الثاني، بعد ما شلنا منها:
/// الباركود، الصوت، منطق الـ VIN، و ScanChasehController.
///
/// الاستخدام:
///   final sku = await Get.to<String>(() => const TextScannerScreen());
/// بترجع النص اللي أكده المستخدم، أو null لو رجع من غير تأكيد.
class TextScannerScreen extends StatefulWidget {
  const TextScannerScreen({super.key});

  @override
  State<TextScannerScreen> createState() => _TextScannerScreenState();
}

class _TextScannerScreenState extends State<TextScannerScreen>
    with WidgetsBindingObserver {
  final TextRecognizer _textRecognizer = TextRecognizer();
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _isInitializingCamera = false;
  String? _cameraErrorMessage;

  double _frameHeight = 110;
  static const double _minFrameHeight = 60;
  static const double _maxFrameHeight = 220;

  Size _rotatedPreviewSize() {
    final ps = _cameraController!.value.previewSize!;
    return Size(ps.height, ps.width);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initCamera();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCameraController();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ================= Camera Init =================
  Future<void> _initCamera() async {
    if (_cameraController != null || _isInitializingCamera) return;

    setState(() {
      _isInitializingCamera = true;
      _cameraErrorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(
            () => _cameraErrorMessage = 'No camera found on this device.',
          );
        }
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _cameraErrorMessage = null;
      });
    } on CameraException catch (e) {
      debugPrint('Camera exception (${e.code}): ${e.description}');
      if (mounted) {
        final msg = switch (e.code) {
          'CameraAccessDenied' =>
            'Camera permission was denied. Please allow access and retry.',
          'CameraAccessDeniedWithoutPrompt' =>
            'Camera access is denied and cannot be requested again. Open Settings and allow camera access.',
          'CameraAccessRestricted' =>
            'Camera access is restricted on this device.',
          _ => 'Failed to initialize camera.',
        };
        setState(() => _cameraErrorMessage = msg);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() => _cameraErrorMessage = 'Failed to initialize camera.');
      }
    } finally {
      if (mounted) setState(() => _isInitializingCamera = false);
    }
  }

  Future<void> _disposeCameraController() async {
    final ctrl = _cameraController;
    _cameraController = null;
    _isCameraReady = false;
    await ctrl?.dispose();
  }

  // ================= Capture + OCR =================
  Future<void> _captureImage() async {
    if (_cameraController == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final file = await _cameraController!.takePicture();
      await _extractTextFromImage(file.path);
    } catch (e) {
      debugPrint('Capture Error: $e');
      Get.snackbar(
        'Capture Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  /// موقع المستطيل بإحداثيات طبيعية (0..1) نسبةً إلى الـ preview
  Rect _frameRectNormalizedInPreview(Size screen) {
    final preview = _rotatedPreviewSize();

    final scale = math.max(
      screen.width / preview.width,
      screen.height / preview.height,
    );
    final dispW = preview.width * scale;
    final dispH = preview.height * scale;
    final offX = (dispW - screen.width) / 2;
    final offY = (dispH - screen.height) / 2;

    final frameTop = (screen.height - _frameHeight) / 2;
    final frameBottom = frameTop + _frameHeight;

    return Rect.fromLTRB(
      (0 + offX) / dispW,
      (frameTop + offY) / dispH,
      (screen.width + offX) / dispW,
      (frameBottom + offY) / dispH,
    );
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    if (_cameraController == null) return;

    // نقرأ القيم قبل أي await
    final screenSize = MediaQuery.of(context).size;
    final norm = _frameRectNormalizedInPreview(screenSize);
    final preview = _rotatedPreviewSize();

    // 1) قص الصورة على حدود المستطيل فقط
    final croppedPath = await compute(
      _cropImageToFrame,
      _CropParams(
        path: imagePath,
        left: norm.left,
        top: norm.top,
        right: norm.right,
        bottom: norm.bottom,
        previewAspect: preview.width / preview.height,
      ),
    );

    // 2) OCR على الجزء المقصوص
    final recognized = await _textRecognizer.processImage(
      InputImage.fromFilePath(croppedPath),
    );

    final text = _cleanRecognizedText(recognized);

    if (!mounted) return;

    if (text.isEmpty) {
      Get.rawSnackbar(
        message: 'لم يتم العثور على نص، قرّب الكاميرا أو عدّل المستطيل',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // 3) نعرض الصورة المقصوصة + النص قابل للتعديل
    final confirmed = await _showResultDialog(croppedPath, text);

    if (!mounted) return;
    if (confirmed != null && confirmed.trim().isNotEmpty) {
      Get.back(result: confirmed.trim()); // نرجّع النص لصفحة الإضافة
    }
  }

  String _cleanRecognizedText(RecognizedText recognized) {
    final lines = <String>[
      for (final block in recognized.blocks)
        for (final line in block.lines) line.text.trim(),
    ].where((l) => l.isNotEmpty).toList();

    return lines.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _focusOnFrame() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    const point = Offset(0.5, 0.5);
    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(point);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setExposurePoint(point);
    } catch (e) {
      debugPrint('Focus set error: $e');
    }
  }

  /// بيرجع النص بعد التعديل لو المستخدم أكد، أو null لو اختار إعادة التقاط
  Future<String?> _showResultDialog(String imagePath, String extractedText) {
    final textCtrl = TextEditingController(text: extractedText);

    return showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                color: Colors.black,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 140,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: textCtrl,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('إعادة التقاط'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final value = textCtrl.text.trim();
                        if (value.isEmpty) return;
                        Navigator.of(ctx).pop(value);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('استخدام'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed ────────────────────────────────────
          Positioned.fill(
            child: _isCameraReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _rotatedPreviewSize().width,
                      height: _rotatedPreviewSize().height,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: _cameraErrorMessage != null
                        ? _CameraErrorView(
                            message: _cameraErrorMessage!,
                            onRetry: _initCamera,
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
          ),

          // ── Overlay 50% مع فتحة بحجم المستطيل ─────────────
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScannerOverlayPainter(
                  frameWidth: MediaQuery.of(context).size.width,
                  frameHeight: _frameHeight,
                ),
              ),
            ),
          ),

          // ── Top gradient ───────────────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Bottom gradient ────────────────────────────────
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Top bar ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'قراءة SKU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),

          // ── Scan frame (resizable) ─────────────────────────
          Center(
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: screenWidth,
                      height: _frameHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                    const Positioned(
                      top: 0,
                      left: 0,
                      child: _Corner(Alignment.topLeft),
                    ),
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: _Corner(Alignment.topRight),
                    ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      child: _Corner(Alignment.bottomLeft),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: _Corner(Alignment.bottomRight),
                    ),
                    Positioned(
                      bottom: -14,
                      left: screenWidth / 2 - 15,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _frameHeight = (_frameHeight + details.delta.dy)
                                .clamp(_minFrameHeight, _maxFrameHeight);
                          });
                        },
                        onPanEnd: (_) => _focusOnFrame(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.height_rounded,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Capture button ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: GestureDetector(
                    onTap: (_isProcessing || !_isCameraReady)
                        ? null
                        : _captureImage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProcessing ? Colors.white38 : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3457D5).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isProcessing
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF3457D5),
                              ),
                            )
                          : Icon(
                              Icons.text_fields_rounded,
                              color: !_isCameraReady
                                  ? Colors.grey
                                  : const Color(0xFF3457D5),
                              size: 32,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// قص الصورة على حدود المستطيل (في isolate منفصل عبر compute)
// ═══════════════════════════════════════════════════════════════════════════
class _CropParams {
  final String path;
  final double left, top, right, bottom;
  final double previewAspect;

  const _CropParams({
    required this.path,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.previewAspect,
  });
}

String _cropImageToFrame(_CropParams p) {
  final bytes = File(p.path).readAsBytesSync();
  var image = img.decodeImage(bytes);
  if (image == null) return p.path;

  image = img.bakeOrientation(image);

  final imgW = image.width.toDouble();
  final imgH = image.height.toDouble();

  double visW = imgW, visH = imgH;
  if (imgW / imgH > p.previewAspect) {
    visW = imgH * p.previewAspect;
  } else {
    visH = imgW / p.previewAspect;
  }
  final visX = (imgW - visW) / 2;
  final visY = (imgH - visH) / 2;

  final margin = (p.bottom - p.top) * 0.08;
  final l = p.left.clamp(0.0, 1.0).toDouble();
  final r = p.right.clamp(0.0, 1.0).toDouble();
  final t = (p.top - margin).clamp(0.0, 1.0).toDouble();
  final b = (p.bottom + margin).clamp(0.0, 1.0).toDouble();

  final x = (visX + l * visW).round().clamp(0, image.width - 1).toInt();
  final y = (visY + t * visH).round().clamp(0, image.height - 1).toInt();
  final w = ((r - l) * visW).round().clamp(1, image.width - x).toInt();
  final h = ((b - t) * visH).round().clamp(1, image.height - y).toInt();

  var cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);

  if (cropped.width < 1600) {
    cropped = img.copyResize(
      cropped,
      width: 1600,
      interpolation: img.Interpolation.cubic,
    );
  }
  cropped = img.grayscale(cropped);
  cropped = img.adjustColor(cropped, contrast: 1.3);

  final outPath =
      '${Directory.systemTemp.path}/sku_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
  File(outPath).writeAsBytesSync(img.encodeJpg(cropped, quality: 95));
  return outPath;
}

// ═══════════════════════════════════════════════════════════════════════════
// Widgets
// ═══════════════════════════════════════════════════════════════════════════
class _ScannerOverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  _ScannerOverlayPainter({required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(holeRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight;
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner(this.alignment);

  @override
  Widget build(BuildContext context) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(
          painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  const _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double x = isLeft ? 0 : size.width;
    final double y = isTop ? 0 : size.height;
    final double dx = isLeft ? size.width : -size.width;
    final double dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CameraErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white70,
                size: 46,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                  ElevatedButton(
                    onPressed: openAppSettings,
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
