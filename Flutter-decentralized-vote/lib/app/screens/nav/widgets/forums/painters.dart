import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';

/// HeatmapPainter — Activity heatmap cells
class HeatmapPainter extends CustomPainter {
  final List<double> values; // 0.0–1.0 per cell
  final Color activeColor;
  final Color inactiveColor;

  const HeatmapPainter({
    required this.values,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final cellSize = size.width / values.length;
    final padding = cellSize * 0.15;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final x = i * cellSize + padding;
      final w = cellSize - padding * 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, padding, w, size.height - padding * 2),
        Radius.circular(2),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = v > 0
              ? activeColor.withOpacity(0.15 + 0.75 * v)
              : inactiveColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter old) => old.values != values;
}

/// TimerArcPainter — Circular countdown arc
class TimerArcPainter extends CustomPainter {
  final double progress; // 0.0–1.0
  final Color color;

  const TimerArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 2;

    // Background track (full circle)
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = TColors.darkBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Progress arc (clockwise from top)
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2, // start at top (12 o'clock)
        2 * math.pi * progress, // sweep angle proportional to remaining time
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimerArcPainter old) =>
      old.progress != progress || old.color != color;
}

/// UpvoteBurstPainter — Gold particle burst on upvote
class UpvoteBurstPainter extends CustomPainter {
  final double progress; // 0.0–1.0
  final Color color;

  const UpvoteBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const particleCount = 8;
    const maxRadius = 24.0;
    const particleSize = 3.0;

    // Opacity fades in last 40% of animation
    final opacity = progress < 0.6 ? 1.0 : 1.0 - (progress - 0.6) / 0.4;

    for (int i = 0; i < particleCount; i++) {
      final angle = (2 * math.pi / particleCount) * i;
      final dist = maxRadius * progress;
      final px = center.dx + dist * math.cos(angle);
      final py = center.dy + dist * math.sin(angle);

      canvas.drawCircle(
        Offset(px, py),
        particleSize * (1.0 - progress * 0.5), // shrink slightly
        Paint()..color = color.withOpacity(opacity.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant UpvoteBurstPainter old) =>
      old.progress != progress;
}

class HexRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (int ring = 1; ring <= 3; ring++) {
      final r = size.width * 0.15 * ring;
      final p = Path();
      for (int i = 0; i < 6; i++) {
        final a = (math.pi / 3) * i - math.pi / 6;
        final x = c.dx + r * math.cos(a);
        final y = c.dy + r * math.sin(a);
        if (i == 0)
          p.moveTo(x, y);
        else
          p.lineTo(x, y);
      }
      p.close();
      canvas.drawPath(
        p,
        Paint()
          ..color = TColors.secondary.withOpacity(0.5 / ring)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final a = (math.pi / 3) * i - math.pi / 6;
      if (i == 0)
        hexPath.moveTo(
          c.dx + r * 0.9 * math.cos(a),
          c.dy + r * 0.9 * math.sin(a),
        );
      else
        hexPath.lineTo(
          c.dx + r * 0.9 * math.cos(a),
          c.dy + r * 0.9 * math.sin(a),
        );
    }
    hexPath.close();
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = TColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c, r * 0.55, Paint()..color = TColors.primary);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.22, c.dy)
        ..lineTo(c.dx - r * 0.04, c.dy + r * 0.18)
        ..lineTo(c.dx + r * 0.24, c.dy - r * 0.2),
      Paint()
        ..color = TColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
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
    const s = 36.0;
    for (double x = 0; x <= size.width; x += s)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y <= size.height; y += s)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
