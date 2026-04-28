import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

// ═══════════════════════════════════════════════
//  SpeakUp Decorative Painters
//  Painted curves, swooshes, and accent shapes
//  using CustomPainter for layered compositions.
// ═══════════════════════════════════════════════

/// A flowing, multi-layer gradient swoosh.
/// Stacks 2–3 translucent Bezier ribbon layers.
///
/// ```dart
/// CustomPaint(
///   size: Size(double.infinity, 260),
///   painter: SSwooshPainter(
///     colors: [TColors.primary, TColors.screenShare],
///     isDark: true,
///   ),
/// )
/// ```
class SSwooshPainter extends CustomPainter {
  final List<Color> colors;
  final bool isDark;
  final double intensity;

  SSwooshPainter({
    required this.colors,
    this.isDark = true,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseAlpha = isDark ? 0.15 : 0.10;

    // Layer 1 — wide background swoosh
    final p1 = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.2, h * 0.3, w * 0.5, h * 0.7, w, h * 0.35)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors[0].withValues(alpha: baseAlpha * intensity),
          (colors.length > 1 ? colors[1] : colors[0])
              .withValues(alpha: baseAlpha * 0.6 * intensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(p1, paint1);

    // Layer 2 — sharper mid-swoosh
    final p2 = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.65, h * 0.85, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          colors[0].withValues(alpha: baseAlpha * 0.7 * intensity),
          (colors.length > 1 ? colors[1] : colors[0])
              .withValues(alpha: baseAlpha * 0.4 * intensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(p2, paint2);

    // Layer 3 — thin accent line along the top edge of the main swoosh
    final p3 = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.35, h * 0.45, w * 0.65, h * 0.85, w, h * 0.6);

    final linePaint = Paint()
      ..color = colors[0].withValues(alpha: isDark ? 0.2 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(p3, linePaint);
  }

  @override
  bool shouldRepaint(SSwooshPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      isDark != oldDelegate.isDark ||
      intensity != oldDelegate.intensity;
}

/// Animated-ready aurora / northern-lights effect.
/// Multiple overlapping gradient arcs.
class SAuroraPainter extends CustomPainter {
  final List<Color> colors;
  final double phase;
  final bool isDark;

  SAuroraPainter({
    required this.colors,
    this.phase = 0.0,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < colors.length; i++) {
      final t = (phase + i * 0.7) % (math.pi * 2);
      final yOffset = math.sin(t) * h * 0.1;

      final path = Path()
        ..moveTo(-w * 0.1, h * (0.3 + i * 0.12) + yOffset)
        ..cubicTo(
          w * 0.25, h * (0.15 + i * 0.08) + yOffset,
          w * 0.75, h * (0.45 + i * 0.06) + yOffset,
          w * 1.1, h * (0.2 + i * 0.1) + yOffset,
        );

      final paint = Paint()
        ..color = colors[i].withValues(alpha: isDark ? 0.08 : 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40 + i * 15.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SAuroraPainter oldDelegate) =>
      colors != oldDelegate.colors ||
      phase != oldDelegate.phase ||
      isDark != oldDelegate.isDark;
}

/// Geometric accent — a rotated diamond/rhombus shape.
/// Use as a floating decorative element.
class SDiamondPainter extends CustomPainter {
  final Color color;
  final double rotation;
  final bool filled;

  SDiamondPainter({
    required this.color,
    this.rotation = math.pi / 4,
    this.filled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2.2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(0, -r)
      ..lineTo(r, 0)
      ..lineTo(0, r)
      ..lineTo(-r, 0)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SDiamondPainter oldDelegate) =>
      color != oldDelegate.color ||
      rotation != oldDelegate.rotation ||
      filled != oldDelegate.filled;
}

/// Corner gradient arc — a curved accent in one corner.
/// Typically placed top-right or bottom-left.
class SCornerArcPainter extends CustomPainter {
  final Color color;
  final double radius;
  final CornerPosition corner;

  SCornerArcPainter({
    required this.color,
    this.radius = 200,
    this.corner = CornerPosition.topRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center;
    switch (corner) {
      case CornerPosition.topLeft:
        center = Offset.zero;
      case CornerPosition.topRight:
        center = Offset(size.width, 0);
      case CornerPosition.bottomLeft:
        center = Offset(0, size.height);
      case CornerPosition.bottomRight:
        center = Offset(size.width, size.height);
    }

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(SCornerArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      corner != oldDelegate.corner;
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

/// Noise-grain texture overlay for a premium matte finish.
/// Apply over gradients for added depth.
class SGrainPainter extends CustomPainter {
  final double opacity;
  final int density;

  SGrainPainter({this.opacity = 0.03, this.density = 3000});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(12345);
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);

    for (int i = 0; i < density; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(SGrainPainter oldDelegate) =>
      opacity != oldDelegate.opacity || density != oldDelegate.density;
}

/// VoteSecure Mini Logo — hexagonal stroke with checkmark
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
      if (i == 0)
        hexPath.moveTo(x, y);
      else
        hexPath.lineTo(x, y);
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

    final checkPath = Path()
      ..moveTo(c.dx - r * 0.22, c.dy)
      ..lineTo(c.dx - r * 0.04, c.dy + r * 0.18)
      ..lineTo(c.dx + r * 0.24, c.dy - r * 0.2);
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = TColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

/// Large decorative hexagon ring for corner accents
class HexRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    for (int ring = 1; ring <= 3; ring++) {
      final r = size.width * 0.15 * ring;
      final hexPath = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (math.pi / 3) * i - math.pi / 6;
        final x = c.dx + r * math.cos(angle);
        final y = c.dy + r * math.sin(angle);
        if (i == 0)
          hexPath.moveTo(x, y);
        else
          hexPath.lineTo(x, y);
      }
      hexPath.close();
      canvas.drawPath(
        hexPath,
        Paint()
          ..color = TColors.secondary.withValues(alpha: 0.5 / ring)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

/// Wallet icon in hexagonal outline style
class WalletIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = c.dx + r * 0.9 * math.cos(angle);
      final y = c.dy + r * 0.9 * math.sin(angle);
      if (i == 0)
        hexPath.moveTo(x, y);
      else
        hexPath.lineTo(x, y);
    }
    hexPath.close();
    canvas.drawPath(
      hexPath,
      Paint()
        ..color = TColors.secondary.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Inner W glyph
    final wPaint = Paint()
      ..color = TColors.secondary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final wPath = Path()
      ..moveTo(c.dx - r * 0.35, c.dy - r * 0.15)
      ..lineTo(c.dx - r * 0.18, c.dy + r * 0.25)
      ..lineTo(c.dx, c.dy)
      ..lineTo(c.dx + r * 0.18, c.dy + r * 0.25)
      ..lineTo(c.dx + r * 0.35, c.dy - r * 0.15);
    canvas.drawPath(wPath, wPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

/// Simple grid texture painter
class AuthGridPainter extends CustomPainter {
  final Color color;
  const AuthGridPainter({required this.color});

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
  bool shouldRepaint(covariant CustomPainter _) => false;
}

/// SkillRadarPainter — Pentagon radar chart
class SkillRadarPainter extends CustomPainter {
  final List<double> scores; // 5 values 0.0–1.0
  final double progress; // 0.0–1.0 from entrance animation
  final Color fillColor;
  final Color strokeColor;
  final Color gridColor;

  const SkillRadarPainter({
    required this.scores,
    required this.progress,
    required this.fillColor,
    required this.strokeColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2 * 0.85;
    const n = 5;

    // Axis angles: start from top, rotate evenly
    List<double> axisAngles = List.generate(
      n,
      (i) => -math.pi / 2 + (2 * math.pi / n) * i,
    );

    // Grid rings
    for (int ring = 1; ring <= 4; ring++) {
      final r = maxR * ring / 4;
      final ringPath = Path();
      for (int i = 0; i < n; i++) {
        final x = center.dx + r * math.cos(axisAngles[i]);
        final y = center.dy + r * math.sin(axisAngles[i]);
        if (i == 0)
          ringPath.moveTo(x, y);
        else
          ringPath.lineTo(x, y);
      }
      ringPath.close();
      canvas.drawPath(
        ringPath,
        Paint()
          ..color = gridColor.withOpacity(ring == 4 ? 0.4 : 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // Axis lines from center to vertex
    for (int i = 0; i < n; i++) {
      canvas.drawLine(
        center,
        Offset(
          center.dx + maxR * math.cos(axisAngles[i]),
          center.dy + maxR * math.sin(axisAngles[i]),
        ),
        Paint()
          ..color = gridColor.withOpacity(0.3)
          ..strokeWidth = 0.6,
      );
    }

    // Score polygon — animated via progress
    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final r = maxR * scores[i] * progress;
      final x = center.dx + r * math.cos(axisAngles[i]);
      final y = center.dy + r * math.sin(axisAngles[i]);
      if (i == 0)
        dataPath.moveTo(x, y);
      else
        dataPath.lineTo(x, y);
    }
    dataPath.close();

    // Fill
    canvas.drawPath(dataPath, Paint()..color = fillColor);

    // Stroke
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = strokeColor.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Score vertex dots
    for (int i = 0; i < n; i++) {
      final r = maxR * scores[i] * progress;
      canvas.drawCircle(
        Offset(
          center.dx + r * math.cos(axisAngles[i]),
          center.dy + r * math.sin(axisAngles[i]),
        ),
        3,
        Paint()..color = strokeColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SkillRadarPainter old) =>
      old.progress != progress || old.scores != scores;
}

/// MilestonePainter — Horizontal dotted timeline
class MilestonePainter extends CustomPainter {
  final int total;
  final int achieved;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final List<String> labels;

  const MilestonePainter({
    required this.total,
    required this.achieved,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final spacing = size.width / (total - 1 == 0 ? 1 : total - 1);
    const nodeR = 6.0;
    const lineY = 10.0;

    // Draw connectors first (behind nodes)
    for (int i = 0; i < total - 1; i++) {
      final x1 = i * spacing + nodeR;
      final x2 = (i + 1) * spacing - nodeR;
      final segmentProgress = ((progress * total) - i).clamp(0.0, 1.0);
      final endX = x1 + (x2 - x1) * segmentProgress;

      // Active connector
      if (i < achieved) {
        _drawDashedLine(
          canvas,
          Offset(x1, lineY),
          Offset(endX, lineY),
          activeColor.withOpacity(0.6),
        );
      } else {
        _drawDashedLine(
          canvas,
          Offset(x1, lineY),
          Offset(endX, lineY),
          inactiveColor,
        );
      }
    }

    // Draw nodes
    for (int i = 0; i < total; i++) {
      final x = i * spacing;
      final nodeProgress = ((progress * total) - i).clamp(0.0, 1.0);
      final r = nodeR * nodeProgress;
      final isDone = i < achieved;

      // Node circle
      canvas.drawCircle(
        Offset(x, lineY),
        r,
        Paint()
          ..color = isDone
              ? activeColor.withOpacity(0.15)
              : const Color(0xFF16162C),
      );
      canvas.drawCircle(
        Offset(x, lineY),
        r,
        Paint()
          ..color = isDone ? activeColor.withOpacity(0.85) : inactiveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Check or number
      if (isDone && r > 3) {
        final tp = TextPainter(
          text: TextSpan(
            text: '✓',
            style: TextStyle(
              color: activeColor,
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, lineY - tp.height / 2));
      }

      // Label below
      if (i < labels.length && nodeProgress > 0.5) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              fontFamily: 'Inter',
              color: isDone ? activeColor.withOpacity(0.8) : inactiveColor,
              fontSize: 8,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, lineY + nodeR + 4));
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    final dashPath = Path();
    const dashLen = 4.0;
    const gapLen = 3.0;
    var dist = 0.0;
    bool drawing = true;
    for (final metric in path.computeMetrics()) {
      while (dist < metric.length) {
        final seg = drawing ? dashLen : gapLen;
        final end = math.min(dist + seg, metric.length);
        if (drawing) {
          final t1 = metric.getTangentForOffset(dist)!.position;
          final t2 = metric.getTangentForOffset(end)!.position;
          dashPath.moveTo(t1.dx, t1.dy);
          dashPath.lineTo(t2.dx, t2.dy);
        }
        dist += seg;
        drawing = !drawing;
      }
    }
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = color
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant MilestonePainter old) =>
      old.progress != progress || old.achieved != achieved;
}

/// WaveformPainter — Approval rating history waveform
class WaveformPainter extends CustomPainter {
  final List<double> values;
  final Color activeColor;
  final Color inactiveColor;

  const WaveformPainter({
    required this.values,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final barW = (size.width / values.length) * 0.55;
    final gap = size.width / values.length;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final barH = size.height * v;
      final x = i * gap + (gap - barW) / 2;
      final y = size.height - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, barH),
          const Radius.circular(2),
        ),
        Paint()
          ..color = Color.lerp(
            inactiveColor,
            activeColor,
            v,
          )!.withOpacity(0.7 + 0.3 * v),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter old) => old.values != values;
}

/// RadialGlowPainter — Ambient radial glow behind spotlight card
class RadialGlowPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const RadialGlowPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    canvas.drawCircle(
      center,
      size.width * 0.6,
      Paint()
        ..shader =
            RadialGradient(
              colors: [color.withOpacity(opacity), Colors.transparent],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.6),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant RadialGlowPainter old) =>
      old.opacity != opacity;
}
