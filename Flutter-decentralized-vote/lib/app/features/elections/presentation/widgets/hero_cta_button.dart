import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

class HeroCTAButton extends StatelessWidget {
  final double pulse;
  const HeroCTAButton({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: CustomPaint(
        painter: PulsingRingPainter(
          progress: pulse,
          color: TColors.accent,
          isCircle: true,
        ),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: TColors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: TColors.accent.withOpacity(0.3 + 0.2 * pulse),
                blurRadius: 16 + 6 * pulse,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.how_to_vote_outlined, color: TColors.white, size: 22),
              SizedBox(height: 2),
              Text(
                'Vote',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
