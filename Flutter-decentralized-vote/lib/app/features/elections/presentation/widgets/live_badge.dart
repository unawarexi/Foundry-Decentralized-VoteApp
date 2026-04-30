import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

class LiveBadge extends StatelessWidget {
  final double pulse;
  final String label;
  const LiveBadge({super.key, required this.pulse, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TColors.success.withOpacity(0.08 + 0.05 * pulse),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: TColors.success.withOpacity(0.3 + 0.2 * pulse),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.success.withOpacity(0.7 + 0.3 * pulse),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: TColors.success,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
