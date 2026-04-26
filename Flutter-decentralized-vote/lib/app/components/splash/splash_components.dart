import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';

// ──────────────────────────────────────────────────────────────
// Custom Logo Mark — hexagonal ballot-seal hybrid
// ──────────────────────────────────────────────────────────────
class VoteSecureLogo extends StatelessWidget {
  final double size;
  const VoteSecureLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _LogoPainter());
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Outer hexagon (gold stroke)
    final hexPaint = Paint()
      ..color = TColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = center.dx + r * 0.9 * math.cos(angle);
      final y = center.dy + r * 0.9 * math.sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, hexPaint);

    // Inner circle (primary green fill)
    final circlePaint = Paint()
      ..color = TColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 0.58, circlePaint);

    // Inner circle border (gold)
    final circleBorder = Paint()
      ..color = TColors.secondary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, r * 0.58, circleBorder);

    // Checkmark / ballot mark (white)
    final checkPaint = Paint()
      ..color = TColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(center.dx - r * 0.22, center.dy);
    checkPath.lineTo(center.dx - r * 0.04, center.dy + r * 0.18);
    checkPath.lineTo(center.dx + r * 0.24, center.dy - r * 0.2);
    canvas.drawPath(checkPath, checkPaint);

    // Four corner dots (gold — like a seal)
    final dotPaint = Paint()
      ..color = TColors.secondary.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = center.dx + r * 0.72 * math.cos(angle);
      final y = center.dy + r * 0.72 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────
// Subtle grid background painter
// ──────────────────────────────────────────────────────────────
class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  const GridPainter({required this.color, this.spacing = 40.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
