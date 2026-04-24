import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';


class TTextFormFieldTheme {
  TTextFormFieldTheme._(); // Private constructor to prevent instantiation

  // Light Theme InputDecorationTheme
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: TColors.textSecondary,
    suffixIconColor: TColors.textSecondary,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: TColors.textSecondary,
    ),
    hintStyle: const TextStyle().copyWith(color: TColors.textSecondary),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: TColors.error,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: TColors.primaryBlue,
      fontWeight: FontWeight.w500,
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.borderLight, width: 1),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.borderLight, width: 1),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.primaryBlue, width: 2),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.error, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.warning, width: 2),
    ),
    fillColor: TColors.lightCard,
    filled: true,
  );

  // Dark Theme InputDecorationTheme
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: TColors.textDarkSecondary,
    suffixIconColor: TColors.textDarkSecondary,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: TColors.textDarkSecondary,
    ),
    hintStyle: const TextStyle().copyWith(color: TColors.textDarkSecondary),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: TColors.error,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: TColors.primaryBlue,
      fontWeight: FontWeight.w500,
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.borderDark, width: 1),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.borderDark, width: 1),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.primaryBlue, width: 2),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.error, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      borderSide: const BorderSide(color: TColors.warning, width: 2),
    ),
    fillColor: TColors.darkCard,
    filled: true,
  );

  // Additional Web3-themed input decoration styles
  // static InputDecoration web3InputDecoration({
  //   String? labelText,
  //   String? hintText,
  //   Widget? prefixIcon,
  //   Widget? suffixIcon,
  //   bool isDark = false,
  // }) {
  //   return InputDecoration(
  //     labelText: labelText,
  //     hintText: hintText,
  //     prefixIcon: prefixIcon,
  //     suffixIcon: suffixIcon,
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(14),
  //       borderSide: BorderSide(
  //         color: isDark ? TColors.borderDark : TColors.borderLight,
  //       ),
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(14),
  //       borderSide: BorderSide(
  //         color: isDark ? TColors.borderDark : TColors.borderLight,
  //       ),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(14),
  //       borderSide: const BorderSide(color: TColors.primaryBlue, width: 2),
  //     ),
  //     errorBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(14),
  //       borderSide: const BorderSide(color: TColors.error),
  //     ),
  //     fillColor: isDark ? TColors.darkCard : TColors.lightCard,
  //     filled: true,
  //     labelStyle: TextStyle(
  //       color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
  //     ),
  //     hintStyle: TextStyle(
  //       color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
  //     ),
  //     floatingLabelStyle: const TextStyle(
  //       color: TColors.primaryBlue,
  //       fontWeight: FontWeight.w500,
  //     ),
  //   );
  // }

  // // Crypto address input style
  // static InputDecoration cryptoAddressInputDecoration({bool isDark = false}) {
  //   return web3InputDecoration(
  //     labelText: 'Wallet Address',
  //     hintText: '0x...',
  //     isDark: isDark,
  //   ).copyWith(
  //     prefixIcon: const Icon(Icons.account_balance_wallet),
  //     prefixIconColor: TColors.crypto,
  //   );
  // }

  // // Search input style
  // static InputDecoration searchInputDecoration({bool isDark = false}) {
  //   return web3InputDecoration(hintText: 'Search...', isDark: isDark).copyWith(
  //     prefixIcon: const Icon(Icons.search),
  //     prefixIconColor: isDark
  //         ? TColors.textDarkSecondary
  //         : TColors.textSecondary,
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(25),
  //       borderSide: BorderSide.none,
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(25),
  //       borderSide: BorderSide.none,
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(25),
  //       borderSide: const BorderSide(color: TColors.primaryBlue, width: 2),
  //     ),
  //   );
  // }
}
