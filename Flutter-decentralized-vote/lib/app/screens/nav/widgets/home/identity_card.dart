import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/widgets/spinners.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'accent_tag.dart';
import 'live_dot.dart';
import 'card_detail_chip.dart';
import 'status_pill.dart';

class HomeIdentityCard extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Animation<double> pulseAnim;

  const HomeIdentityCard({
    super.key,
    required this.fade,
    required this.slide,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: AnimatedBuilder(
          listenable: pulseAnim,
          builder: (_, __) => Container(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2A1E), Color(0xFF12112A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TColors.secondary.withOpacity(
                  0.22 + 0.1 * pulseAnim.value,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(isDark ? 0.35 : 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.06,
                    child: CustomPaint(
                      size: const Size(120, 120),
                      painter: HexRingPainter(color: TColors.secondary),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AccentTag(label: 'VERIFIED VOTER'),
                        const Spacer(),
                        LiveDot(pulse: pulseAnim.value),
                        const SizedBox(width: 6),
                        const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: TColors.success,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Adebayo Okonkwo',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSerif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: TColors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Benin City · Edo State · Nigeria',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFB0B0B0),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        CardDetailChip(
                          label: 'VOTER ID',
                          value: 'NG·EDO·2024·7743',
                          mono: true,
                        ),
                        SizedBox(width: 12),
                        CardDetailChip(label: 'REGION', value: 'South·South'),
                        SizedBox(width: 12),
                        CardDetailChip(
                          label: 'BLOCKCHAIN HASH',
                          value: '0x8B...F2A',
                          mono: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: TColors.secondary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const StatusPill(
                          icon: Icons.fingerprint,
                          label: 'Biometric',
                          active: true,
                        ),
                        const SizedBox(width: 8),
                        const StatusPill(
                          icon: Icons.shield_outlined,
                          label: 'ZK Proof',
                          active: true,
                        ),
                        SizedBox(width: 8),
                        StatusPill(
                          icon: Icons.link_rounded,
                          label: 'On-Chain',
                          active: true,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: CustomPaint(
                            painter: PulsingRingPainter(
                              progress: pulseAnim.value,
                              color: TColors.accent,
                              isCircle: false,
                              borderRadius: 8,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.accent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: TColors.accent.withOpacity(
                                      0.35 + 0.15 * pulseAnim.value,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Cast Vote',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TColors.white,
                                ),
                              ),
                            ),
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
    );
  }
}
