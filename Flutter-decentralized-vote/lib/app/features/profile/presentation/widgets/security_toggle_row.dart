import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class SecurityToggleRow extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool enabled;

  const SecurityToggleRow({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.enabled,
  });

  @override
  State<SecurityToggleRow> createState() => _SecurityToggleRowState();
}

class _SecurityToggleRowState extends State<SecurityToggleRow> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 16,
            color: _enabled 
                ? TColors.secondary 
                : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _enabled = !_enabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 20,
              decoration: BoxDecoration(
                color: _enabled ? TColors.primary : (isDark ? TColors.darkElevated : TColors.lightElevated),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _enabled
                      ? TColors.secondary.withOpacity(0.4)
                      : (isDark ? TColors.darkBorder : TColors.lightBorder),
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _enabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _enabled
                        ? TColors.secondary
                        : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
