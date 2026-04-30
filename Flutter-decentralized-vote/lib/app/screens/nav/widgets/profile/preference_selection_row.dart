import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

class PreferenceSelectionRow<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<PreferenceOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const PreferenceSelectionRow({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: TColors.secondary),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkElevated : TColors.lightElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
            ),
            child: Row(
              children: options.map((opt) {
                final isSelected = opt.value == selectedValue;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(opt.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? TColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? TColors.secondary.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? TColors.secondary
                                : (isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class PreferenceOption<T> {
  final String label;
  final T value;

  const PreferenceOption({required this.label, required this.value});
}
