import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'accent_tag.dart';

class ProfileHeroHeader extends StatelessWidget {
  final Animation<double> heroFade;
  final Animation<Offset> heroSlide;
  final Animation<double> heroScale;
  final Animation<double> heroGlow;
  final Animation<double> zkRotation;
  final Animation<double> pulseAnim;

  const ProfileHeroHeader({
    super.key,
    required this.heroFade,
    required this.heroSlide,
    required this.heroScale,
    required this.heroGlow,
    required this.zkRotation,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: heroFade,
      child: SlideTransition(
        position: heroSlide,
        child: ScaleTransition(
          scale: heroScale,
          child: AnimatedBuilder(
            animation: Listenable.merge([heroGlow, pulseAnim]),
            builder: (_, __) => ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    80 + MediaQuery.of(context).padding.top,
                    20,
                    24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0B1E14),
                        const Color(0xFF0D0D1E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: TColors.secondary.withOpacity(
                          0.18 + 0.08 * heroGlow.value,
                        ),
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -20,
                        top: -20,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: RadialGlowPainter(
                            color: TColors.primary,
                            opacity: 0.10 + 0.16 * heroGlow.value,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: zkRotation,
                                    builder: (_, __) => SizedBox(
                                      width: 74,
                                      height: 74,
                                      child: CustomPaint(
                                        painter: ZKProofCirclePainter(
                                          rotation: zkRotation.value,
                                          color: TColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF0B3D2E),
                                          Color(0xFF1A1A40),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: TColors.secondary.withOpacity(
                                          0.45 + 0.15 * pulseAnim.value,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'AO',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexSerif',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: TColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? TColors.darkElevated
                                            : TColors.lightElevated,
                                        border: Border.all(
                                          color: TColors.secondary.withOpacity(
                                            0.4,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.5),
                                        child: CustomPaint(
                                          painter: MiniLogoPainter(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Adebayo Okonkwo',
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexSerif',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 11,
                                          color: TColors.textDarkTertiary,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Benin City · Edo State · Nigeria',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10.5,
                                            color: TColors.textDarkTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 6,
                                      children: const [
                                        AccentTag(label: 'VERIFIED VOTER'),
                                        AccentTag(label: 'REGION-LOCKED'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? TColors.darkCard
                                      : TColors.lightCard,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: isDark
                                        ? TColors.darkBorder
                                        : TColors.lightBorder,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: isDark
                                      ? TColors.textDarkTertiary
                                      : TColors.textLightTertiary,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 36,
                            height: 1.5,
                            color: TColors.secondary,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                'VOTER ID',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: TColors.textDarkTertiary,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'NG · EDO · 2024 · 7743A',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TColors.secondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Spacer(),
                              AnimatedBuilder(
                                animation: pulseAnim,
                                builder: (_, __) => Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: TColors.success,
                                        boxShadow: [
                                          BoxShadow(
                                            color: TColors.success.withOpacity(
                                              0.4 * pulseAnim.value,
                                            ),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'ZK SYNCED',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: TColors.success,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
