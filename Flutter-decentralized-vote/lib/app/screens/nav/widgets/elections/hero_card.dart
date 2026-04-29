import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import '../home/accent_tag.dart';
import '../home/painters.dart';
import 'live_badge.dart';
import 'countdown_block.dart';
import 'participation_bar.dart';
import 'hero_stat.dart';
import 'hero_cta_button.dart';
import 'elections_data.dart';

class HeroCard extends StatelessWidget {
  final Animation<double> heroFade;
  final Animation<Offset> heroSlide;
  final Animation<double> pulseAnim;
  final Duration countdown;

  const HeroCard({
    super.key,
    required this.heroFade,
    required this.heroSlide,
    required this.pulseAnim,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final h = countdown.inHours;
    final m = countdown.inMinutes.remainder(60);
    final s = countdown.inSeconds.remainder(60);

    return FadeTransition(
      opacity: heroFade,
      child: SlideTransition(
        position: heroSlide,
        child: AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2A1E), Color(0xFF12112A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: TColors.secondary.withOpacity(
                  0.3 + 0.15 * pulseAnim.value,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(
                    isDark
                        ? 0.3 + 0.1 * pulseAnim.value
                        : 0.1 + 0.05 * pulseAnim.value,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Watermark hex (top-right)
                Positioned(
                  top: -30,
                  right: -30,
                  child: Opacity(
                    opacity: 0.07,
                    child: CustomPaint(
                      size: const Size(160, 160),
                      painter: const HexRingPainter(),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: tag + FEATURED badge
                      Row(
                        children: [
                          const AccentTag(label: 'STATE · FEATURED'),
                          const Spacer(),
                          LiveBadge(pulse: pulseAnim.value, label: 'LIVE'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Election title
                      Text(
                        'Edo State Gubernatorial\nElection 2024',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: TColors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: TColors.textDarkTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Benin City · Edo State · Nigeria',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: TColors.textDarkTertiary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Gold rule
                      Container(
                        width: 36,
                        height: 1.5,
                        color: TColors.secondary,
                      ),

                      const SizedBox(height: 20),

                      // Countdown row
                      Row(
                        children: [
                          CountdownBlock(
                            value: h.toString().padLeft(2, '0'),
                            label: 'HRS',
                          ),
                          const CountdownSeparator(),
                          CountdownBlock(
                            value: m.toString().padLeft(2, '0'),
                            label: 'MIN',
                          ),
                          const CountdownSeparator(),
                          CountdownBlock(
                            value: s.toString().padLeft(2, '0'),
                            label: 'SEC',
                          ),
                          const Spacer(),
                          // Cast vote CTA
                          HeroCTAButton(pulse: pulseAnim.value),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Participation bar
                      ParticipationBar(
                        percent: 68,
                        entranceAnim: heroFade,
                      ),

                      const SizedBox(height: 16),

                      // Stat row: candidates · registered voters · fee · privacy
                      Row(
                        children: const [
                          HeroStat(value: '7', label: 'Candidates'),
                          HeroStatDivider(),
                          HeroStat(value: '2.4M', label: 'Registered'),
                          HeroStatDivider(),
                          HeroStat(value: '\$1 USDT', label: 'Vote Fee'),
                          HeroStatDivider(),
                          HeroStat(value: 'ZK', label: 'Privacy'),
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
