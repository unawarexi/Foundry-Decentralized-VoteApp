import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

class LiveDot extends StatelessWidget {
  final double pulse;
  const LiveDot({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse ring
        Container(
          width: 12 + 4 * pulse,
          height: 12 + 4 * pulse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TColors.success.withOpacity(0.15 * (1 - pulse)),
          ),
        ),
        // Core dot
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: TColors.success,
          ),
        ),
      ],
    );
  }
}
