import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'accent_tag.dart';

class VoterIDCard extends StatelessWidget {
  final Animation<double> verifyFade;
  final Animation<Offset> verifySlide;
  final Animation<double> pulseAnim;

  const VoterIDCard({
    super.key,
    required this.verifyFade,
    required this.verifySlide,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: verifyFade,
      child: SlideTransition(
        position: verifySlide,
        child: AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2B1E), Color(0xFF12112A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: TColors.secondary.withOpacity(
                  0.28 + 0.1 * pulseAnim.value,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(
                    0.25 + 0.1 * pulseAnim.value,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: VoterIDCardPainter(
                        lineColor: TColors.secondary.withOpacity(0.06),
                        accentColor: TColors.secondary.withOpacity(0.15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CustomPaint(
                              painter: MiniLogoPainter(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'VOTESECURE',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSerif',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TColors.white,
                              letterSpacing: 3,
                            ),
                          ),
                          const Spacer(),
                          const AccentTag(label: 'VOTER CARD'),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADEBAYO OKONKWO',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSerif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: TColors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'NG · EDO · 2024 · 7743A',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 11,
                                  color: TColors.secondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'ACTIVITY',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  color: TColors.textDarkTertiary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 56,
                                height: 10,
                                child: CustomPaint(
                                  painter: HeatmapPainter(
                                    values: const [
                                      0.3,
                                      1.0,
                                      0.2,
                                      0.8,
                                      0.0,
                                      0.6,
                                      1.0,
                                      0.7,
                                    ],
                                    activeColor: TColors.secondary,
                                    inactiveColor: TColors.darkBorder,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
