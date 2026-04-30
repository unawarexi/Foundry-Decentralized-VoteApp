import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

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

class SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.ctrl,
    required this.focus,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? TColors.secondary.withOpacity(0.4)
              : TColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(color: TColors.secondary.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: TColors.secondary.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const SheetDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: TColors.secondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? TColors.darkCard : TColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: isDark ? TColors.darkCard : TColors.lightCard,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
              size: 18,
            ),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
            ),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final delay = i * 0.25;
          final v = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
          final opacity = math.sin(v * math.pi).clamp(0.2, 1.0);
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.white.withOpacity(opacity),
            ),
          );
        }),
      ),
    );
  }
}

class ForumSectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final Animation<double> opacity;

  const ForumSectionLabel({
    super.key,
    required this.label,
    required this.count,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return FadeTransition(
      opacity: opacity,
      child: Row(
        children: [
          AccentTag(label: label),
          const SizedBox(width: 10),
          Text(
            '$count questions',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

