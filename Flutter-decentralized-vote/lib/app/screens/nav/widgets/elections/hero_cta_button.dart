import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

class HeroCTAButton extends StatelessWidget {
  final double pulse;
  const HeroCTAButton({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: TColors.accent.withOpacity(0.3 + 0.2 * pulse),
              blurRadius: 16 + 6 * pulse,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: const [
            Icon(Icons.how_to_vote_outlined, color: TColors.white, size: 20),
            SizedBox(height: 4),
            Text(
              'Vote',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: TColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
