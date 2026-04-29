import 'package:flutter/material.dart';

class CardDetailChip extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const CardDetailChip({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    // Note: This widget is primarily used on dark gradient backgrounds (Identity Card)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 8.5,
            color: Color(0xFF71717A), // Muted light gray
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: mono ? 'IBMPlexMono' : 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFB0B0B0), // Secondary light gray
            letterSpacing: mono ? 0.5 : 0,
          ),
        ),
      ],
    );
  }
}
