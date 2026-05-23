import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get tagline => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 13,
        height: 1.55,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get appTitle => GoogleFonts.inter(
        color: AppColors.white,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: 6,
      );

  static TextStyle get authTitle => GoogleFonts.inter(
        color: AppColors.white,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      );

  /// Sign-in / sign-up screens — monospaced like the reference.
  static TextStyle get authTitleMono => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
      );

  static TextStyle get authFieldLabel => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get authFieldInput => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get authButton => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get authDividerOr => GoogleFonts.spaceMono(
        color: AppColors.white.withValues(alpha: 0.85),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get authFooterItalic => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 13,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get authFooterBoldItalic => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 13,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get footer => GoogleFonts.inter(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get footerBold => GoogleFonts.inter(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get dividerOr => GoogleFonts.inter(
        color: AppColors.white.withValues(alpha: 0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get fieldLabel => GoogleFonts.inter(
        color: AppColors.inputHint,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get button => GoogleFonts.inter(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get chatInputHint => GoogleFonts.spaceMono(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get chatTodayLabel => GoogleFonts.spaceMono(
        color: AppColors.white,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get chatWelcome => GoogleFonts.spaceMono(
        color: AppColors.black,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get chatMessageText => GoogleFonts.spaceMono(
        color: AppColors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );
}
