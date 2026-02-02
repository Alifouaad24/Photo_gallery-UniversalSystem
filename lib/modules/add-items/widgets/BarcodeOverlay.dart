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
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 100,
    );
    paint.blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
