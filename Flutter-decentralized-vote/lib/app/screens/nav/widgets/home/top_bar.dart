import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/animations/animations.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'painters.dart';
import 'notification_bell.dart';
import 'avatar_chip.dart';

class HomeTopBar extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final double collapse;
  final Animation<double> pulseAnim;
  final VoidCallback? onNotificationTap;

  const HomeTopBar({
    super.key,
    required this.fade,
    required this.slide,
    required this.collapse,
    required this.pulseAnim,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: AnimatedContainer(
          duration: TAnimations.normal,
          padding: EdgeInsets.fromLTRB(TSizes.pagePadding, 16, TSizes.pagePadding, 12 - 4 * collapse),
          decoration: BoxDecoration(
            color: collapse > 0.5
                ? (isDark ? TColors.darkSurface : TColors.lightSurface).withOpacity(collapse * 0.95)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: (isDark ? TColors.darkBorder : TColors.lightBorder).withOpacity(collapse),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(painter: MiniLogoPainter()),
              ),
              const SizedBox(width: 10),
              AnimatedOpacity(
                duration: TAnimations.normal,
                opacity: collapse < 0.6 ? 1.0 : 0.0,
                child: Text(
                  'VOTESECURE',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSerif',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TColors.white : TColors.primary,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onNotificationTap,
                child: NotificationBell(pulseAnim: pulseAnim),
              ),
              const SizedBox(width: 12),
              const AvatarChip(),
            ],
          ),
        ),
      ),
    );
  }
}
