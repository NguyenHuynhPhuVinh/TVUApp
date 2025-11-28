import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Duolingo-style design tokens (như Tailwind CSS)
class AppStyles {
  AppStyles._();

  // ============ SPACING (như Tailwind spacing) ============
  static double get space0 => 0;
  static double get space1 => 4.w;
  static double get space2 => 8.w;
  static double get space3 => 12.w;
  static double get space4 => 16.w;
  static double get space5 => 20.w;
  static double get space6 => 24.w;
  static double get space8 => 32.w;
  static double get space10 => 40.w;
  static double get space12 => 48.w;
  static double get space16 => 64.w;

  // ============ BORDER RADIUS (Duolingo style - bo tròn nhiều) ============
  static double get radiusNone => 0;
  static double get radiusSm => 4.r;
  static double get radiusMd => 8.r;
  static double get radiusLg => 12.r;
  static double get radiusXl => 16.r;
  static double get radius2xl => 20.r;
  static double get radius3xl => 24.r;
  static double get radius4xl => 28.r;
  static double get radiusFull => 9999.r;

  // BorderRadius presets
  static BorderRadius get roundedNone => BorderRadius.zero;
  static BorderRadius get roundedSm => BorderRadius.circular(radiusSm);
  static BorderRadius get roundedMd => BorderRadius.circular(radiusMd);
  static BorderRadius get roundedLg => BorderRadius.circular(radiusLg);
  static BorderRadius get roundedXl => BorderRadius.circular(radiusXl);
  static BorderRadius get rounded2xl => BorderRadius.circular(radius2xl);
  static BorderRadius get rounded3xl => BorderRadius.circular(radius3xl);
  static BorderRadius get rounded4xl => BorderRadius.circular(radius4xl);
  static BorderRadius get roundedFull => BorderRadius.circular(radiusFull);

  // ============ BORDER WIDTH ============
  static double get borderNone => 0;
  static double get border1 => 1;
  static double get border2 => 2;
  static double get border3 => 3;
  static double get border4 => 4;

  // ============ FONT SIZES ============
  static double get textXs => 12.sp;
  static double get textSm => 14.sp;
  static double get textBase => 16.sp;
  static double get textLg => 18.sp;
  static double get textXl => 20.sp;
  static double get text2xl => 24.sp;
  static double get text3xl => 28.sp;
  static double get text4xl => 32.sp;
  static double get text5xl => 36.sp;

  // ============ FONT WEIGHTS ============
  static FontWeight get fontNormal => FontWeight.w400;
  static FontWeight get fontMedium => FontWeight.w500;
  static FontWeight get fontSemibold => FontWeight.w600;
  static FontWeight get fontBold => FontWeight.w700;
  static FontWeight get fontExtrabold => FontWeight.w800;

  // ============ LINE HEIGHTS ============
  static double get leadingTight => 1.25;
  static double get leadingNormal => 1.5;
  static double get leadingRelaxed => 1.75;

  // ============ SHADOWS (Duolingo 3D style) ============
  static double get shadowSm => 2;
  static double get shadowMd => 4;
  static double get shadowLg => 6;
  static double get shadowXl => 8;

  // ============ ICON SIZES ============
  static double get iconXs => 16.sp;
  static double get iconSm => 20.sp;
  static double get iconMd => 24.sp;
  static double get iconLg => 28.sp;
  static double get iconXl => 32.sp;
  static double get icon2xl => 40.sp;
  static double get icon3xl => 48.sp;

  // ============ BUTTON HEIGHTS ============
  static double get buttonSm => 36.h;
  static double get buttonMd => 44.h;
  static double get buttonLg => 52.h;
  static double get buttonXl => 56.h;

  // ============ INPUT HEIGHTS ============
  static double get inputSm => 40.h;
  static double get inputMd => 48.h;
  static double get inputLg => 56.h;

  // ============ AVATAR SIZES ============
  static double get avatarSm => 32.w;
  static double get avatarMd => 40.w;
  static double get avatarLg => 48.w;
  static double get avatarXl => 64.w;
  static double get avatar2xl => 80.w;
  static double get avatar3xl => 120.w;

  // ============ CARD SIZES ============
  static double get cardPaddingSm => 12.w;
  static double get cardPaddingMd => 16.w;
  static double get cardPaddingLg => 20.w;
  static double get cardPaddingXl => 24.w;

  // ============ ANIMATION DURATIONS ============
  static Duration get durationFast => const Duration(milliseconds: 150);
  static Duration get durationNormal => const Duration(milliseconds: 300);
  static Duration get durationSlow => const Duration(milliseconds: 500);
  static Duration get durationSlowest => const Duration(milliseconds: 800);

  // ============ ANIMATION CURVES ============
  static Curve get easeIn => Curves.easeIn;
  static Curve get easeOut => Curves.easeOut;
  static Curve get easeInOut => Curves.easeInOut;
  static Curve get bounce => Curves.elasticOut;
  static Curve get spring => Curves.elasticInOut;
}
