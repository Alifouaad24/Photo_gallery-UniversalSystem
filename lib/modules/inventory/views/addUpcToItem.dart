import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// -------- Design tokens (نفس ألوان الشاشة التانية عشان التناسق) --------
class _Palette {
  static const ink = Color(0xFF1B1F27);
  static const primary = Color(0xFF3457D5);
  static const primarySoft = Color(0xFFEFF2FF);
  static const success = Color(0xFF16A34A);
}

/// شاشة فتح الكاميرا وقراءة الباركود.
/// بترجع القيمة (String) عن طريق Navigator.pop / Get.back لما تنجح القراءة.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  String? _lastCode;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_lastCode != null) return; // منع القراءة المتكررة
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _lastCode = value);

    // رجّع القيمة بعد لحظة بسيطة عشان المستخدم يشوف تأكيد النجاح
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) Navigator.of(context).pop(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "امسح الباركود",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          /// -------- طبقة تعتيم + إطار المسح --------
          _ScannerOverlay(success: _lastCode != null),

          /// -------- نص إرشادي / تأكيد --------
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _lastCode != null
                  ? _ResultBadge(code: _lastCode!)
                  : const _HintBadge(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final bool success;
  const _ScannerOverlay({required this.success});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(
              color: success ? _Palette.success : Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _HintBadge extends StatelessWidget {
  const _HintBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('hint'),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "وجّه الكاميرا نحو الباركود داخل الإطار",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String code;
  const _ResultBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('result'),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: _Palette.success,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "تم قراءة الباركود: $code",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}