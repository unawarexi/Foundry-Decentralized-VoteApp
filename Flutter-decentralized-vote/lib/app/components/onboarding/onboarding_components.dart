import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';

// ──────────────────────────────────────────────────────────────
// Accent tag pill
// ──────────────────────────────────────────────────────────────
class AccentTag extends StatelessWidget {
  final String label;
  const AccentTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.secondary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: TColors.secondary.withOpacity(0.08),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: TColors.secondary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Slide data model
// ──────────────────────────────────────────────────────────────
enum SlideVisual { identity, regionLock, blockchain, transparency, governance }

class OnboardSlide {
  final String tag;
  final String headline;
  final String body;
  final SlideVisual visual;
  final String accentLabel;

  const OnboardSlide({
    required this.tag,
    required this.headline,
    required this.body,
    required this.visual,
    required this.accentLabel,
  });
}

// ──────────────────────────────────────────────────────────────
// Slide illustrations — custom-painted for each slide
// ──────────────────────────────────────────────────────────────
class SlideIllustration extends StatelessWidget {
  final SlideVisual visual;
  final int index;
  final double animationValue;

  const SlideIllustration({
    super.key,
    required this.visual,
    required this.index,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: TColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.darkBorder),
        ),
        child: CustomPaint(
          painter: _getIllustrationPainter(visual, animationValue),
          child: Container(),
        ),
      ),
    );
  }

  CustomPainter _getIllustrationPainter(SlideVisual v, double animValue) {
    switch (v) {
      case SlideVisual.identity:
        return IdentityIllustration(progress: animValue);
      case SlideVisual.regionLock:
        return RegionLockIllustration(progress: animValue);
      case SlideVisual.blockchain:
        return BlockchainIllustration(progress: animValue);
      case SlideVisual.transparency:
        return TransparencyIllustration(progress: animValue);
      case SlideVisual.governance:
        return GovernanceIllustration(progress: animValue);
    }
  }
}

// ── Illustration 1: Identity / Biometric ─────────────────────
class IdentityIllustration extends CustomPainter {
  final double progress;
  const IdentityIllustration({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Background ambient glow
    canvas.drawCircle(
      c,
      size.width * 0.4 * progress,
      Paint()
        ..shader = RadialGradient(
          colors: [TColors.primary.withOpacity(0.25), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.4)),
    );

    // Face scan rings
    for (int i = 1; i <= 4; i++) {
      final r = size.width * 0.08 * i * progress;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = TColors.secondary.withOpacity(0.12 * (5 - i))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // Central face icon outline
    final facePaint = Paint()
      ..color = TColors.secondary.withOpacity(0.9 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Head circle
    canvas.drawCircle(c, size.width * 0.13, facePaint);

    // Shoulders arc
    final shoulderPath = Path();
    shoulderPath.addArc(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + size.width * 0.22),
        width: size.width * 0.32,
        height: size.width * 0.18,
      ),
      math.pi,
      math.pi,
    );
    canvas.drawPath(shoulderPath, facePaint);

    // Scan line
    final scanY = c.dy - size.width * 0.15 + size.width * 0.3 * progress;
    canvas.drawLine(
      Offset(c.dx - size.width * 0.18, scanY),
      Offset(c.dx + size.width * 0.18, scanY),
      Paint()
        ..color = TColors.accent.withOpacity(0.6 * progress)
        ..strokeWidth = 1.2,
    );

    // Corner brackets
    final bracketPaint = Paint()
      ..color = TColors.secondary.withOpacity(0.6 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    final br = size.width * 0.34;
    final bl = 18.0;
    _drawCornerBrackets(canvas, c, br, bl, bracketPaint);

    // ZK text label
    _drawLabel(
      canvas,
      size,
      'ZK IDENTITY',
      TColors.secondary,
      Offset(c.dx, size.height * 0.85),
      progress,
    );
  }

  void _drawCornerBrackets(
    Canvas canvas,
    Offset c,
    double r,
    double l,
    Paint p,
  ) {
    // top-left
    canvas.drawLine(
      Offset(c.dx - r, c.dy - r),
      Offset(c.dx - r + l, c.dy - r),
      p,
    );
    canvas.drawLine(
      Offset(c.dx - r, c.dy - r),
      Offset(c.dx - r, c.dy - r + l),
      p,
    );
    // top-right
    canvas.drawLine(
      Offset(c.dx + r, c.dy - r),
      Offset(c.dx + r - l, c.dy - r),
      p,
    );
    canvas.drawLine(
      Offset(c.dx + r, c.dy - r),
      Offset(c.dx + r, c.dy - r + l),
      p,
    );
    // bottom-left
    canvas.drawLine(
      Offset(c.dx - r, c.dy + r),
      Offset(c.dx - r + l, c.dy + r),
      p,
    );
    canvas.drawLine(
      Offset(c.dx - r, c.dy + r),
      Offset(c.dx - r, c.dy + r - l),
      p,
    );
    // bottom-right
    canvas.drawLine(
      Offset(c.dx + r, c.dy + r),
      Offset(c.dx + r - l, c.dy + r),
      p,
    );
    canvas.drawLine(
      Offset(c.dx + r, c.dy + r),
      Offset(c.dx + r, c.dy + r - l),
      p,
    );
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    String text,
    Color color,
    Offset pos,
    double opacity,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withOpacity(opacity),
          fontSize: 10,
          fontFamily: 'Inter',
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant IdentityIllustration old) =>
      old.progress != progress;
}

// ── Illustration 2: Region Lock / Globe ──────────────────────
class RegionLockIllustration extends CustomPainter {
  final double progress;
  const RegionLockIllustration({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.48);
    final r = size.width * 0.3;

    // Globe circle
    canvas.drawCircle(
      c,
      r * progress,
      Paint()
        ..color = TColors.primary.withOpacity(0.4)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      c,
      r * progress,
      Paint()
        ..color = TColors.secondary.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Latitude lines
    for (int i = 1; i <= 3; i++) {
      final lat = c.dy - r * 0.3 * (i - 2);
      final hw = r * math.sqrt(1 - math.pow(0.3 * (i - 2), 2));
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(c.dx, lat),
          width: hw * 2,
          height: r * 0.3,
        ),
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = TColors.secondary.withOpacity(0.15 * progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }

    // Longitude lines
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) * i;
      canvas.drawArc(
        Rect.fromCenter(center: c, width: r * 2, height: r * 2 * 0.5),
        angle,
        math.pi,
        false,
        Paint()
          ..color = TColors.secondary.withOpacity(0.15 * progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }

    // Region highlight pin
    final pinPos = Offset(c.dx + r * 0.22, c.dy - r * 0.18);
    canvas.drawCircle(
      pinPos,
      8 * progress,
      Paint()..color = TColors.accent.withOpacity(0.85 * progress),
    );
    canvas.drawCircle(
      pinPos,
      14 * progress,
      Paint()
        ..color = TColors.accent.withOpacity(0.25 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Lock icon below globe
    final lockCenter = Offset(c.dx, c.dy + r + 32);
    _drawLock(canvas, lockCenter, 18, progress);
  }

  void _drawLock(Canvas canvas, Offset center, double size, double p) {
    // Lock body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.15),
        width: size * 1.2,
        height: size * 0.9,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = TColors.secondary.withOpacity(0.7 * p)
        ..style = PaintingStyle.fill,
    );

    // Lock shackle
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size * 0.1),
        width: size * 0.7,
        height: size * 0.8,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = TColors.secondary.withOpacity(0.7 * p)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant RegionLockIllustration old) =>
      old.progress != progress;
}

// ── Illustration 3: Blockchain / Nodes ───────────────────────
class BlockchainIllustration extends CustomPainter {
  final double progress;
  const BlockchainIllustration({required this.progress});

  static final List<Offset> _nodeOffsets = [
    const Offset(0.5, 0.2),
    const Offset(0.2, 0.42),
    const Offset(0.8, 0.42),
    const Offset(0.35, 0.65),
    const Offset(0.65, 0.65),
    const Offset(0.5, 0.82),
  ];

  static final List<List<int>> _edges = [
    [0, 1],
    [0, 2],
    [1, 3],
    [2, 4],
    [3, 5],
    [4, 5],
    [1, 2],
    [3, 4],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = _nodeOffsets
        .map((o) => Offset(o.dx * size.width, o.dy * size.height))
        .toList();

    // Edges
    for (final edge in _edges) {
      canvas.drawLine(
        nodes[edge[0]],
        nodes[edge[1]],
        Paint()
          ..color = TColors.secondary.withOpacity(0.18 * progress)
          ..strokeWidth = 1,
      );
    }

    // Nodes
    for (int i = 0; i < nodes.length; i++) {
      final delay = i / nodes.length;
      final p = ((progress - delay * 0.4) / 0.6).clamp(0.0, 1.0);

      canvas.drawCircle(
        nodes[i],
        10 * p,
        Paint()..color = TColors.primary.withOpacity(0.8),
      );
      canvas.drawCircle(
        nodes[i],
        10 * p,
        Paint()
          ..color = TColors.secondary.withOpacity(0.6 * p)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Hash label inside node
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: TColors.secondary.withOpacity(p),
            fontSize: 8,
            fontFamily: 'IBMPlexMono',
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(nodes[i].dx - tp.width / 2, nodes[i].dy - tp.height / 2),
      );
    }

    // Center badge
    final midNode = nodes[0];
    _drawHashBadge(canvas, midNode, progress);
  }

  void _drawHashBadge(Canvas canvas, Offset pos, double p) {
    // Already handled above — draw a small "VERIFIED" text bottom
  }

  @override
  bool shouldRepaint(covariant BlockchainIllustration old) =>
      old.progress != progress;
}

// ── Illustration 4: Global Transparency ──────────────────────
class TransparencyIllustration extends CustomPainter {
  final double progress;
  const TransparencyIllustration({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal bar chart — live election results
    final bars = [0.82, 0.54, 0.68, 0.33, 0.91];
    final colors = [
      TColors.secondary,
      TColors.primary,
      TColors.accent,
      TColors.darkBorder,
      TColors.secondary,
    ];
    final labels = ['NG', 'US', 'UK', 'DE', 'JP'];

    final chartLeft = size.width * 0.18;
    final chartRight = size.width * 0.86;
    final startY = size.height * 0.18;
    final rowH = size.height * 0.13;

    for (int i = 0; i < bars.length; i++) {
      final y = startY + i * rowH;
      final barW = (chartRight - chartLeft) * bars[i] * progress;

      // Track
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(chartLeft, y, chartRight - chartLeft, 12),
          const Radius.circular(3),
        ),
        Paint()..color = TColors.darkBorder,
      );

      // Fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(chartLeft, y, barW, 12),
          const Radius.circular(3),
        ),
        Paint()
          ..shader = LinearGradient(
            colors: [colors[i].withOpacity(0.9), colors[i].withOpacity(0.5)],
          ).createShader(Rect.fromLTWH(chartLeft, y, barW, 12)),
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: TColors.textDarkTertiary.withOpacity(progress),
            fontSize: 9,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartLeft - 26, y - 1));

      // Percentage
      final pct = '${(bars[i] * 100 * progress).toStringAsFixed(0)}%';
      final ptp = TextPainter(
        text: TextSpan(
          text: pct,
          style: TextStyle(
            color: TColors.secondary.withOpacity(progress),
            fontSize: 9,
            fontFamily: 'IBMPlexMono',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      ptp.paint(canvas, Offset(chartLeft + barW + 4, y - 1));
    }

    // Header
    final header = TextPainter(
      text: TextSpan(
        text: 'LIVE RESULTS — GLOBAL',
        style: TextStyle(
          color: TColors.secondary.withOpacity(progress * 0.7),
          fontSize: 9,
          letterSpacing: 2,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    header.paint(canvas, Offset(chartLeft, startY - 22));
  }

  @override
  bool shouldRepaint(covariant TransparencyIllustration old) =>
      old.progress != progress;
}

// ── Illustration 5: Governance layers ────────────────────────
class GovernanceIllustration extends CustomPainter {
  final double progress;
  const GovernanceIllustration({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final levels = [
      ('HEAD OF STATE', 0.12, TColors.secondary, 1.0),
      ('GOVERNOR', 0.27, TColors.primary, 0.9),
      ('MAYOR', 0.42, TColors.accent, 0.8),
      ('UNIVERSITY', 0.57, TColors.secondary, 0.65),
      ('SCHOOL', 0.72, TColors.primary, 0.5),
    ];

    for (final lvl in levels) {
      final y = size.height * lvl.$2;
      final delay = levels.indexOf(lvl) * 0.12;
      final p = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);

      final w = size.width * lvl.$4 * 0.72 * p;
      final left = (size.width - w) / 2;

      // Pyramid bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, y, w, 18),
          const Radius.circular(4),
        ),
        Paint()..color = lvl.$3.withOpacity(0.18),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, y, w, 18),
          const Radius.circular(4),
        ),
        Paint()
          ..color = lvl.$3.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: lvl.$1,
          style: TextStyle(
            color: lvl.$3.withOpacity(p),
            fontSize: 9,
            fontFamily: 'Inter',
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, y + 4));
    }
  }

  @override
  bool shouldRepaint(covariant GovernanceIllustration old) =>
      old.progress != progress;
}

// ──────────────────────────────────────────────────────────────
// Mini logo for top bar
// ──────────────────────────────────────────────────────────────
class MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final hexPaint = Paint()
      ..color = TColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = c.dx + r * 0.9 * math.cos(angle);
      final y = c.dy + r * 0.9 * math.sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, hexPaint);

    canvas.drawCircle(c, r * 0.55, Paint()..color = TColors.primary);

    final checkPaint = Paint()
      ..color = TColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(c.dx - r * 0.22, c.dy);
    checkPath.lineTo(c.dx - r * 0.04, c.dy + r * 0.18);
    checkPath.lineTo(c.dx + r * 0.24, c.dy - r * 0.2);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
