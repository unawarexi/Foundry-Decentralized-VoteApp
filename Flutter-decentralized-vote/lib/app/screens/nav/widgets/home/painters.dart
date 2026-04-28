import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';

class MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = c.dx + r * 0.9 * math.cos(angle);
      final y = c.dy + r * 0.9 * math.sin(angle);
      if (i == 0) hexPath.moveTo(x, y);
      else hexPath.lineTo(x, y);
    }
    hexPath.close();
    canvas.drawPath(hexPath,
        Paint()
          ..color = TColors.secondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(c, r * 0.55, Paint()..color = TColors.primary);
    final checkPath = Path()
      ..moveTo(c.dx - r * 0.22, c.dy)
      ..lineTo(c.dx - r * 0.04, c.dy + r * 0.18)
      ..lineTo(c.dx + r * 0.24, c.dy - r * 0.2);
    canvas.drawPath(checkPath,
        Paint()
          ..color = TColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_) => false;
}

class HexRingPainter extends CustomPainter {
  final Color? color;
  const HexRingPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final baseColor = color ?? TColors.secondary;
    for (int ring = 1; ring <= 3; ring++) {
      final r = size.width * 0.15 * ring;
      final hexPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (math.pi / 3) * i - math.pi / 6;
        final x = c.dx + r * math.cos(angle);
        final y = c.dy + r * math.sin(angle);
        if (i == 0) hexPath.moveTo(x, y);
        else hexPath.lineTo(x, y);
      }
      hexPath.close();
      canvas.drawPath(hexPath,
          Paint()
            ..color = baseColor.withOpacity(0.5 / ring)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class GridPainter extends CustomPainter {
  final Color color;
  const GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const spacing = 36.0;
    for (double x = 0; x <= size.width; x += spacing)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y <= size.height; y += spacing)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
