import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';

// ──────────────────────────────────────────────────────────────
// Illustration 1: Identity / Biometric
// ──────────────────────────────────────────────────────────────
class IdentityIllustration extends CustomPainter {
  final double progress;
  final bool isDark;
  const IdentityIllustration({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Background ambient glow
    canvas.drawCircle(
      c,
      size.width * 0.4 * progress,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (isDark ? TColors.primary : TColors.primaryDark).withOpacity(
              isDark ? 0.25 : 0.15,
            ),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.4)),
    );

    // Face scan rings
    for (int i = 1; i <= 4; i++) {
      final r = size.width * 0.08 * i * progress;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = (isDark ? TColors.secondary : TColors.primary).withOpacity(
            isDark ? 0.12 * (5 - i) : 0.18 * (5 - i),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // Central face icon outline
    final facePaint = Paint()
      ..color = (isDark ? TColors.secondary : TColors.primary).withOpacity(
        0.9 * progress,
      )
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
        ..color = TColors.accent.withOpacity(
          isDark ? 0.6 * progress : 0.8 * progress,
        )
        ..strokeWidth = 1.2,
    );

    // Corner brackets
    final bracketPaint = Paint()
      ..color = (isDark ? TColors.secondary : TColors.primary).withOpacity(
        isDark ? 0.6 * progress : 0.8 * progress,
      )
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
      isDark ? TColors.secondary : TColors.primary,
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
    canvas.drawLine(Offset(c.dx - r, c.dy - r), Offset(c.dx - r + l, c.dy - r), p);
    canvas.drawLine(Offset(c.dx - r, c.dy - r), Offset(c.dx - r, c.dy - r + l), p);
    // top-right
    canvas.drawLine(Offset(c.dx + r, c.dy - r), Offset(c.dx + r - l, c.dy - r), p);
    canvas.drawLine(Offset(c.dx + r, c.dy - r), Offset(c.dx + r, c.dy - r + l), p);
    // bottom-left
    canvas.drawLine(Offset(c.dx - r, c.dy + r), Offset(c.dx - r + l, c.dy + r), p);
    canvas.drawLine(Offset(c.dx - r, c.dy + r), Offset(c.dx - r, c.dy + r - l), p);
    // bottom-right
    canvas.drawLine(Offset(c.dx + r, c.dy + r), Offset(c.dx + r - l, c.dy + r), p);
    canvas.drawLine(Offset(c.dx + r, c.dy + r), Offset(c.dx + r, c.dy + r - l), p);
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

// ──────────────────────────────────────────────────────────────
// Illustration 2: Region Lock / Globe
// ──────────────────────────────────────────────────────────────
class RegionLockIllustration extends CustomPainter {
  final double progress;
  final bool isDark;
  const RegionLockIllustration({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.45);
    final r = size.width * 0.28;

    final primaryColor = isDark ? TColors.primary : TColors.primary;
    final secondaryColor = isDark ? TColors.secondary : TColors.primary;

    // Ambient background glow
    canvas.drawCircle(
      c,
      size.width * 0.45 * progress,
      Paint()
        ..shader = RadialGradient(
          colors: [
            secondaryColor.withOpacity(isDark ? 0.08 : 0.05),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.45)),
    );

    // Globe circle
    canvas.drawCircle(
      c,
      r * progress,
      Paint()
        ..color = primaryColor.withOpacity(isDark ? 0.35 : 0.12)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      c,
      r * progress,
      Paint()
        ..color = secondaryColor.withOpacity(isDark ? 0.4 : 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Latitude lines
    for (int i = 1; i <= 3; i++) {
      final lat = c.dy - r * 0.35 * (i - 2);
      final hw = r * math.sqrt(1 - math.pow(0.35 * (i - 2), 2));
      canvas.drawArc(
        Rect.fromCenter(center: Offset(c.dx, lat), width: hw * 2, height: r * 0.4),
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = secondaryColor.withOpacity(isDark ? 0.12 * progress : 0.25 * progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    // Longitude lines
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 4) * i;
      canvas.drawArc(
        Rect.fromCenter(center: c, width: r * 2, height: r * 2 * 0.45),
        angle,
        math.pi,
        false,
        Paint()
          ..color = secondaryColor.withOpacity(isDark ? 0.12 * progress : 0.25 * progress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    // Radar sweep effect
    final sweepAngle = (progress * math.pi * 2) - (math.pi / 2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      sweepAngle - 0.5,
      0.5,
      true,
      Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          colors: [
            Colors.transparent,
            TColors.accent.withOpacity(0.3 * progress),
          ],
          transform: GradientRotation(sweepAngle - 0.5),
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // AI data orbits
    for (int i = 0; i < 3; i++) {
      final orbitR = r + 25 + i * 15;
      final angle = (progress * (i + 1) * math.pi * 0.5) + (i * math.pi / 3);
      final dotPos = Offset(c.dx + orbitR * math.cos(angle), c.dy + orbitR * math.sin(angle));

      canvas.drawCircle(
        dotPos,
        2.5 * progress,
        Paint()..color = secondaryColor.withOpacity(0.6 * progress),
      );

      canvas.drawLine(
        dotPos,
        Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle)),
        Paint()
          ..color = secondaryColor.withOpacity(0.15 * progress)
          ..strokeWidth = 0.5,
      );
    }

    // Region highlight pin
    final pinPos = Offset(c.dx + r * 0.22, c.dy - r * 0.18);
    canvas.drawCircle(
      pinPos,
      7 * progress,
      Paint()..color = TColors.accent.withOpacity(isDark ? 0.85 * progress : 1.0 * progress),
    );
    canvas.drawCircle(
      pinPos,
      12 * progress,
      Paint()
        ..color = TColors.accent.withOpacity(isDark ? 0.25 * progress : 0.4 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // AI region labels
    final labelStyles = [
      ('AUTHENTICATING IP...', Offset(c.dx - r - 40, c.dy - r + 10)),
      ('GPS CORRELATION', Offset(c.dx + r + 30, c.dy - 10)),
      ('SIM-ID MATCHED', Offset(c.dx - r - 30, c.dy + r - 10)),
    ];

    for (int i = 0; i < labelStyles.length; i++) {
      final l = labelStyles[i];
      final p = ((progress - i * 0.2) / 0.4).clamp(0.0, 1.0);
      if (p > 0) {
        _drawSmallLabel(canvas, l.$1, secondaryColor, l.$2, p);
      }
    }

    // Lock icon badge
    final lockPos = Offset(c.dx, c.dy + r + 35);
    _drawLockBadge(canvas, lockPos, 22, progress, isDark);
  }

  void _drawSmallLabel(Canvas canvas, String text, Color color, Offset pos, double p) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withOpacity(0.6 * p),
          fontSize: 7.5,
          fontFamily: 'IBMPlexMono',
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));

    canvas.drawLine(
      Offset(pos.dx - tp.width / 2, pos.dy + tp.height + 2),
      Offset(pos.dx - tp.width / 2 + tp.width * p, pos.dy + tp.height + 2),
      Paint()
        ..color = TColors.accent.withOpacity(0.4 * p)
        ..strokeWidth = 1,
    );
  }

  void _drawLockBadge(Canvas canvas, Offset center, double size, double p, bool isDark) {
    final secondaryColor = isDark ? TColors.secondary : TColors.primary;
    canvas.drawCircle(center, size * 1.1 * p, Paint()..color = secondaryColor.withOpacity(isDark ? 0.12 : 0.08));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.12), width: size * 0.9, height: size * 0.7),
      const Radius.circular(2),
    );
    canvas.drawRRect(bodyRect, Paint()..color = secondaryColor.withOpacity(isDark ? 0.75 * p : 0.9 * p));

    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy - size * 0.08), width: size * 0.55, height: size * 0.65),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = secondaryColor.withOpacity(isDark ? 0.75 * p : 0.9 * p)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: 'LOCATION AUTHENTICATED',
        style: TextStyle(
          color: TColors.accent.withOpacity(0.9 * p),
          fontSize: 8,
          fontFamily: 'Inter',
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + size + 10));
  }

  @override
  bool shouldRepaint(covariant RegionLockIllustration old) => old.progress != progress;
}

// ──────────────────────────────────────────────────────────────
// Illustration 3: Blockchain / Nodes
// ──────────────────────────────────────────────────────────────
class BlockchainIllustration extends CustomPainter {
  final double progress;
  final bool isDark;
  const BlockchainIllustration({required this.progress, required this.isDark});

  static final List<Offset> _nodeOffsets = [
    const Offset(0.5, 0.22),
    const Offset(0.2, 0.44),
    const Offset(0.8, 0.44),
    const Offset(0.35, 0.68),
    const Offset(0.65, 0.68),
    const Offset(0.5, 0.88),
  ];

  static final List<List<int>> _edges = [
    [0, 1], [0, 2], [1, 3], [2, 4], [3, 5], [4, 5], [1, 2], [3, 4],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = _nodeOffsets.map((o) => Offset(o.dx * size.width, o.dy * size.height)).toList();
    final secondaryColor = isDark ? TColors.secondary : TColors.primary;

    final pathPaint = Paint()
      ..color = secondaryColor.withOpacity((isDark ? 0.12 : 0.2) * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final edge in _edges) {
      final p1 = nodes[edge[0]];
      final p2 = nodes[edge[1]];
      canvas.drawLine(p1, p2, pathPaint);
      
      final t = (progress * 1.5 + edge[0] * 0.1) % 1.0;
      final packetPos = Offset.lerp(p1, p2, t)!;
      canvas.drawCircle(packetPos, 2.5, Paint()..color = TColors.accent.withOpacity(0.5 * progress));
    }

    for (int i = 0; i < nodes.length; i++) {
      final delay = i / nodes.length;
      final p = ((progress - delay * 0.3) / 0.7).clamp(0.0, 1.0);
      if (p <= 0) continue;

      final nodePos = nodes[i];
      final nodeR = 18.0 * p;

      final hexPath = Path();
      for (int j = 0; j < 6; j++) {
        final angle = (math.pi / 3) * j - math.pi / 6;
        final x = nodePos.dx + nodeR * math.cos(angle);
        final y = nodePos.dy + nodeR * math.sin(angle);
        if (j == 0) hexPath.moveTo(x, y);
        else hexPath.lineTo(x, y);
      }
      hexPath.close();

      canvas.drawPath(hexPath, Paint()..color = (isDark ? TColors.darkCard : TColors.white).withOpacity(0.9 * p));
      canvas.drawPath(hexPath, Paint()..color = secondaryColor.withOpacity(0.5 * p)..style = PaintingStyle.stroke..strokeWidth = 1.2);

      final hashes = ['0x7a', '0x2b', '0x9c', '0x4d', '0x1e', '0x8f'];
      final tp = TextPainter(
        text: TextSpan(
          text: hashes[i],
          style: TextStyle(
            color: secondaryColor.withOpacity(0.8 * p),
            fontSize: 7.5,
            fontFamily: 'IBMPlexMono',
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(nodePos.dx - tp.width / 2, nodePos.dy - tp.height / 2));
      
      if (i % 2 == 0) _drawNodeMeta(canvas, nodePos, 'VERIFIED', p);
    }

    final center = nodes[0].translate(0, size.height * 0.25);
    _drawSmartContractShield(canvas, center, progress);
  }

  void _drawNodeMeta(Canvas canvas, Offset pos, String text, double p) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: TColors.accent.withOpacity(0.6 * p),
          fontSize: 6,
          fontFamily: 'Inter',
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx + 22, pos.dy - 10));
  }

  void _drawSmartContractShield(Canvas canvas, Offset pos, double p) {
    final s = 24.0 * p;
    final paint = Paint()..color = TColors.secondary.withOpacity(0.9 * p)..style = PaintingStyle.stroke..strokeWidth = 2.0;

    final shieldPath = Path();
    shieldPath.moveTo(pos.dx, pos.dy - s);
    shieldPath.quadraticBezierTo(pos.dx + s, pos.dy - s, pos.dx + s, pos.dy);
    shieldPath.quadraticBezierTo(pos.dx + s, pos.dy + s, pos.dx, pos.dy + s * 1.4);
    shieldPath.quadraticBezierTo(pos.dx - s, pos.dy + s, pos.dx - s, pos.dy);
    shieldPath.quadraticBezierTo(pos.dx - s, pos.dy - s, pos.dx, pos.dy - s);
    
    canvas.drawPath(shieldPath, paint);
    canvas.drawPath(shieldPath, Paint()..color = TColors.secondary.withOpacity(0.2 * p));

    final checkPaint = Paint()..color = TColors.accent.withOpacity(p)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(pos.dx - 6, pos.dy), Offset(pos.dx - 1, pos.dy + 5), checkPaint);
    canvas.drawLine(Offset(pos.dx - 1, pos.dy + 5), Offset(pos.dx + 7, pos.dy - 6), checkPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: 'IMMUTABLE EVM LEDGER',
        style: TextStyle(
          color: (isDark ? TColors.white : TColors.primary).withOpacity(0.8 * p),
          fontSize: 9,
          fontFamily: 'IBMPlexSerif',
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + s * 1.8));
  }

  @override
  bool shouldRepaint(covariant BlockchainIllustration old) => old.progress != progress;
}

// ──────────────────────────────────────────────────────────────
// Illustration 4: Global Transparency
// ──────────────────────────────────────────────────────────────
class TransparencyIllustration extends CustomPainter {
  final double progress;
  final bool isDark;
  const TransparencyIllustration({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bars = [0.82, 0.54, 0.68, 0.33, 0.91];
    final colors = [TColors.secondary, TColors.primary, TColors.accent, isDark ? TColors.darkBorder : TColors.lightBorder, TColors.secondary];
    final labels = ['NG', 'US', 'UK', 'DE', 'JP'];

    final chartLeft = size.width * 0.18;
    final chartRight = size.width * 0.86;
    final startY = size.height * 0.18;
    final rowH = size.height * 0.13;

    for (int i = 0; i < bars.length; i++) {
      final y = startY + i * rowH;
      final barW = (chartRight - chartLeft) * bars[i] * progress;

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(chartLeft, y, chartRight - chartLeft, 12), const Radius.circular(3)), Paint()..color = isDark ? TColors.darkBorder : TColors.lightBorder);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(chartLeft, y, barW, 12), const Radius.circular(3)), Paint()..shader = LinearGradient(colors: [colors[i].withOpacity(0.9), colors[i].withOpacity(0.5)]).createShader(Rect.fromLTWH(chartLeft, y, barW, 12)));

      final tp = TextPainter(text: TextSpan(text: labels[i], style: TextStyle(color: (isDark ? TColors.textDarkTertiary : TColors.textLightSecondary).withOpacity(progress), fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(chartLeft - 26, y - 1));

      final ptp = TextPainter(text: TextSpan(text: '${(bars[i] * 100 * progress).toStringAsFixed(0)}%', style: TextStyle(color: (isDark ? TColors.secondary : TColors.primary).withOpacity(progress), fontSize: 9, fontFamily: 'IBMPlexMono')), textDirection: TextDirection.ltr)..layout();
      ptp.paint(canvas, Offset(chartLeft + barW + 4, y - 1));
    }

    final header = TextPainter(text: TextSpan(text: 'LIVE RESULTS — GLOBAL', style: TextStyle(color: (isDark ? TColors.secondary : TColors.primary).withOpacity(progress * (isDark ? 0.7 : 0.9)), fontSize: 9, letterSpacing: 2, fontFamily: 'Inter', fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr)..layout();
    header.paint(canvas, Offset(chartLeft, startY - 22));
  }

  @override
  bool shouldRepaint(covariant TransparencyIllustration old) => old.progress != progress;
}

// ──────────────────────────────────────────────────────────────
// Illustration 5: Governance layers
// ──────────────────────────────────────────────────────────────
class GovernanceIllustration extends CustomPainter {
  final double progress;
  final bool isDark;
  const GovernanceIllustration({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final levels = [
      ('HEAD OF STATE', 0.12, isDark ? TColors.secondary : TColors.primary, 1.0),
      ('GOVERNOR', 0.27, isDark ? TColors.primary : TColors.primaryDark, 0.9),
      ('MAYOR', 0.42, TColors.accent, 0.8),
      ('UNIVERSITY', 0.57, isDark ? TColors.secondary : TColors.primary, 0.65),
      ('SCHOOL', 0.72, isDark ? TColors.primary : TColors.primaryDark, 0.5),
    ];

    for (final lvl in levels) {
      final y = size.height * lvl.$2;
      final delay = levels.indexOf(lvl) * 0.12;
      final p = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final w = size.width * lvl.$4 * 0.72 * p;
      final left = (size.width - w) / 2;

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(left, y, w, 18), const Radius.circular(4)), Paint()..color = lvl.$3.withOpacity(isDark ? 0.18 : 0.12));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(left, y, w, 18), const Radius.circular(4)), Paint()..color = lvl.$3.withOpacity(isDark ? 0.6 : 0.8)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      final tp = TextPainter(text: TextSpan(text: lvl.$1, style: TextStyle(color: lvl.$3.withOpacity(p), fontSize: 9, fontFamily: 'Inter', letterSpacing: 1.5, fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, y + 4));
    }
  }

  @override
  bool shouldRepaint(covariant GovernanceIllustration old) => old.progress != progress;
}
