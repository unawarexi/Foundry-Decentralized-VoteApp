import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

class AccentTag extends StatelessWidget {
  final String label;
  const AccentTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.secondary.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: TColors.secondary.withOpacity(0.08),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: TColors.secondary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}
