import 'package:flutter/material.dart' hide AnimatedBuilder;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/widgets/spinners.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class NotificationBell extends StatelessWidget {
  final Animation<double> pulseAnim;
  const NotificationBell({super.key, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return AnimatedBuilder(
      listenable: pulseAnim,
      builder: (_, __) => Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
            ),
            child: Icon(Icons.notifications_outlined,
                color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary, size: 18),
          ),
          // Badge scales between 0.9 and 1.0 to draw attention
          Positioned(
            top: 6,
            right: 6,
            child: Transform.scale(
              scale: 0.9 + 0.1 * pulseAnim.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.accent,
                  border:
                      Border.all(color: isDark ? TColors.darkBackground : TColors.lightBackground, width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
