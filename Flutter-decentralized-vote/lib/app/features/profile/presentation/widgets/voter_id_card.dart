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
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2B1E), Color(0xFF12112A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: TColors.secondary.withOpacity(
                  0.28 + 0.1 * pulseAnim.value,
                ),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(
                    0.25 + 0.1 * pulseAnim.value,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
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
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CustomPaint(
                              painter: MiniLogoPainter(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'VOTESECURE',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSerif',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: TColors.white,
                              letterSpacing: 2,
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
                              const Text(
                                'Adebayo Okonkwo',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSerif',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: TColors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID: 8829-0012-ZK91',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 9,
                                  color: TColors.secondary.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'STATUS',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  color: TColors.white.withOpacity(0.5),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'VERIFIED',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: TColors.success,
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
