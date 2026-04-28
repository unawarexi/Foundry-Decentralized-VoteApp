import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class HomeStatsRow extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;

  const HomeStatsRow({
    super.key,
    required this.fade,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: const Row(
          children: [
            Expanded(child: _StatChip(value: '3', label: 'Elections\nActive', icon: Icons.how_to_vote_outlined)),
            SizedBox(width: 10),
            Expanded(child: _StatChip(value: '12', label: 'Candidates\nFollowed', icon: Icons.person_search_outlined)),
            SizedBox(width: 10),
            Expanded(child: _StatChip(value: '2', label: 'Votes\nCast', icon: Icons.verified_outlined)),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatChip({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: BorderRadius.circular(TSizes.radiusMd),
        border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TColors.secondary, size: 16),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontFamily: 'IBMPlexSerif', fontSize: 24, fontWeight: FontWeight.w700, color: isDark ? TColors.white : TColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: isDark ? TColors.textDarkTertiary : TColors.textLightSecondary, height: 1.4, letterSpacing: 0.2)),
        ],
      ),
    );
  }
}
