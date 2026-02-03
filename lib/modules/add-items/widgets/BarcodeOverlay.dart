import 'package:flutter/material.dart';

class BarcodeOverlay extends StatelessWidget {
  const BarcodeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarcodeOverlayPainter(),
      child: Container(),
    );
  }
}
class _BarcodeOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6);

    final fullScreen = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutOut = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 250,
            height: 100,
          ),
          const Radius.circular(12),
        ),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreen,
      cutOut,
    );

    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

