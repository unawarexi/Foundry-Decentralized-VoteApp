import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/app/components/widgets/spinners.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'home_accent_tag.dart';
import 'home_live_dot.dart';
import 'home/home_card_detail_chip.dart';
import 'home_status_pill.dart';

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
            padding: const EdgeInsets.all(TSizes.cardPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [TColors.primary, TColors.secondaryAlt]
                    : [
                        TColors.primary.withOpacity(0.9),
                        TColors.secondaryAlt.withOpacity(0.8),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(TSizes.radiusLg),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AccentTag(label: 'VOTER ID: 8829-001X'),
                    LiveDot(pulse: pulseAnim.value),
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
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Benin City · Edo State · Nigeria',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CardDetailChip(
                      label: 'POLLING UNIT',
                      value: '002-UGBOWO',
                      mono: true,
                    ),
                    CardDetailChip(
                      label: 'BLOCKCHAIN HASH',
                      value: '0x8B...F2A',
                      mono: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    StatusPill(
                      icon: Icons.verified_user_rounded,
                      label: 'KYC Verified',
                      active: true,
                    ),
                    SizedBox(width: 8),
                    StatusPill(
                      icon: Icons.link_rounded,
                      label: 'On-Chain',
                      active: true,
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
