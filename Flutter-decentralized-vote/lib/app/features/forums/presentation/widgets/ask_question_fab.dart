import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';

class AskQuestionFAB extends StatelessWidget {
  final Animation<double> entrance;
  final Animation<double> float;
  final Animation<double> pulse;
  final VoidCallback onTap;

  const AskQuestionFAB({
    super.key,
    required this.entrance,
    required this.float,
    required this.pulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entrance, float]),
      builder: (_, __) => Transform.translate(
        offset: Offset(0, float.value),
        child: ScaleTransition(
          scale: entrance,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: TColors.accent,
                  borderRadius: BorderRadius.circular(TSizes.radiusLg),
                  border: Border.all(
                    color: TColors.accent.withOpacity(0.5 + 0.2 * pulse.value),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.accent.withOpacity(
                        0.3 + 0.2 * pulse.value,
                      ),
                      blurRadius: 18 + 6 * pulse.value,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add_rounded,
                      color: TColors.white,
                      size: TSizes.iconSm,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ask Question',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TColors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
