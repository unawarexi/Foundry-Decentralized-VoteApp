import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

/// Institutional text input field — outline style, gold focus ring
class VSTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final bool isFocused;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  const VSTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    required this.hint,
    this.isFocused = false,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: controller.text,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: TSizes.animNormal),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: state.hasError
                    ? TColors.error
                    : (isFocused
                        ? TColors.secondary
                        : (THelperFunctions.isDarkMode(context)
                            ? TColors.textDarkTertiary
                            : TColors.textLightTertiary)),
                letterSpacing: 1.5,
              ),
              child: Text(label.toUpperCase()),
            ),
            const SizedBox(height: 6),

            // Field container
            AnimatedContainer(
              duration: const Duration(milliseconds: TSizes.animNormal),
              decoration: BoxDecoration(
                color: THelperFunctions.isDarkMode(context)
                    ? TColors.darkCard
                    : TColors.lightCard,
                borderRadius: BorderRadius.circular(TSizes.radiusSm),
                border: Border.all(
                  color: state.hasError
                      ? TColors.error.withValues(alpha: 0.5)
                      : (isFocused
                          ? TColors.secondary.withValues(alpha: 0.55)
                          : (THelperFunctions.isDarkMode(context)
                              ? TColors.darkBorder
                              : TColors.lightBorder)),
                  width: isFocused || state.hasError ? 1.5 : 1,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: (state.hasError ? TColors.error : TColors.secondary)
                              .withValues(alpha: 0.08),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscureText,
                keyboardType: keyboardType,
                onChanged: (value) {
                  state.didChange(value);
                },
                maxLines: maxLines,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: THelperFunctions.isDarkMode(context)
                      ? TColors.textDarkPrimary
                      : TColors.textLightPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: THelperFunctions.isDarkMode(context)
                        ? TColors.textDarkTertiary
                        : TColors.textLightTertiary,
                  ),
                  prefixIcon: prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: prefixIcon,
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon: suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: suffixIcon,
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  // Hide internal error display
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
              ),
            ),
            
            // Custom Error Message beneath the container
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: TColors.error,
                    height: 1.2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class FieldIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const FieldIcon({super.key, required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: TSizes.animNormal),
      child: Icon(
        icon,
        key: ValueKey(active),
        color: active
            ? TColors.secondary
            : (THelperFunctions.isDarkMode(context)
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary),
        size: TSizes.iconSm,
      ),
    );
  }
}

/// "OR" horizontal divider
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: THelperFunctions.isDarkMode(context)
                ? TColors.darkBorder
                : TColors.lightBorder,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
          child: Text(
            'OR',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: THelperFunctions.isDarkMode(context)
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: THelperFunctions.isDarkMode(context)
                ? TColors.darkBorder
                : TColors.lightBorder,
          ),
        ),
      ],
    );
  }
}

/// Wallet connect CTA — secondary action
class WalletConnectButton extends StatelessWidget {
  const WalletConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: TSizes.inputHeight,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.radiusSm),
          border: Border.all(
            color: THelperFunctions.isDarkMode(context)
                ? TColors.darkBorder
                : TColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wallet hex icon
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: WalletIconPainter()),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue with Wallet',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: THelperFunctions.isDarkMode(context)
                    ? TColors.textDarkSecondary
                    : TColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold accent tag pill
class AuthAccentTag extends StatelessWidget {
  final String label;
  const AuthAccentTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.secondary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(TSizes.radiusXs),
        color: TColors.secondary.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: TColors.secondary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

/// Security badge pill
class SecurityBadge extends StatelessWidget {
  final String label;
  const SecurityBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: THelperFunctions.isDarkMode(context)
              ? TColors.darkBorder
              : TColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(TSizes.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.success,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              color: THelperFunctions.isDarkMode(context)
                  ? TColors.textDarkTertiary
                  : TColors.textLightTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three-dot loading indicator in gold
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
      builder: (_, __) {
        return Row(
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
                color: TColors.secondary.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Premium dropdown for institutional forms
class VSDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const VSDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: TSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 48, // Reduced height for dropdown container
          decoration: BoxDecoration(
            color: isDark ? TColors.darkCard : TColors.lightCard,
            borderRadius: BorderRadius.circular(TSizes.radiusSm),
            border: Border.all(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                ),
              ),
              isExpanded: true,
              dropdownColor: isDark ? TColors.darkCard : TColors.lightCard,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
              ),
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Selection card for ID types or other binary/tertiary choices
class VSSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const VSSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected 
              ? TColors.secondary.withValues(alpha: 0.05) 
              : (isDark ? TColors.darkCard : TColors.lightCard),
          borderRadius: BorderRadius.circular(TSizes.radiusSm),
          border: Border.all(
            color: isSelected ? TColors.secondary : (isDark ? TColors.darkBorder : TColors.lightBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? TColors.secondary : (isDark ? TColors.darkBackground : TColors.lightBackground),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : TColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? TColors.white : TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: TColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Institutional file upload component
class VSFileUpload extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool hasFile;
  final VoidCallback onTap;

  const VSFileUpload({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.hasFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: TSizes.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(TSizes.radiusSm),
              border: Border.all(
                color: hasFile ? TColors.success : (isDark ? TColors.darkBorder : TColors.lightBorder),
                style: hasFile ? BorderStyle.solid : BorderStyle.solid,
                width: hasFile ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.check_circle_rounded : icon,
                  color: hasFile ? TColors.success : TColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile ? 'Document Uploaded' : hint,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? TColors.white : TColors.primary,
                        ),
                      ),
                      if (!hasFile)
                        Text(
                          'Tap to select file',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!hasFile)
                  const Icon(Icons.file_upload_outlined, color: TColors.secondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
