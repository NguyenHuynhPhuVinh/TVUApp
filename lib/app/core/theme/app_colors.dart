import 'package:flutter/material.dart';

/// Bảng màu Duolingo-style với màu chính xanh dương
/// Sử dụng cho toàn bộ app TVU
class AppColors {
  AppColors._();

  // ============ PRIMARY COLORS (Blue) ============
  /// Màu xanh dương chính - dùng cho các element chính
  static const Color primary = Color(0xFF1CB0F6);
  
  /// Màu xanh dương đậm - dùng cho shadow, border, hover state
  static const Color primaryDark = Color(0xFF1899D6);
  
  /// Màu xanh dương nhạt - dùng cho background, highlight
  static const Color primaryLight = Color(0xFF84D8FF);
  
  /// Màu xanh dương rất nhạt - dùng cho subtle background
  static const Color primarySoft = Color(0xFFDDF4FF);

  // ============ ACCENT COLORS ============
  /// Xanh lá - Success, correct, positive actions
  static const Color green = Color(0xFF58CC02);
  static const Color greenDark = Color(0xFF58A700);
  static const Color greenLight = Color(0xFF89E219);
  static const Color greenSoft = Color(0xFFD7FFB8);

  /// Cam - Warning, streak, highlights
  static const Color orange = Color(0xFFFF9600);
  static const Color orangeDark = Color(0xFFE68600);
  static const Color orangeLight = Color(0xFFFFAD33);
  static const Color orangeSoft = Color(0xFFFFE5B8);

  /// Tím - Special, premium, achievements
  static const Color purple = Color(0xFFA560E8);
  static const Color purpleDark = Color(0xFF8B4FCF);
  static const Color purpleLight = Color(0xFFC98EFF);
  static const Color purpleSoft = Color(0xFFF0E5FF);

  /// Đỏ - Error, incorrect, danger
  static const Color red = Color(0xFFFF4B4B);
  static const Color redDark = Color(0xFFEA2B2B);
  static const Color redLight = Color(0xFFFF7878);
  static const Color redSoft = Color(0xFFFFE5E5);

  /// Vàng - XP, coins, rewards
  static const Color yellow = Color(0xFFFFC800);
  static const Color yellowDark = Color(0xFFE6B400);
  static const Color yellowLight = Color(0xFFFFD633);
  static const Color yellowSoft = Color(0xFFFFF4CC);

  // ============ NEUTRAL COLORS ============
  /// Text colors
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textTertiary = Color(0xFFAFAFAF);
  static const Color textDisabled = Color(0xFFCECECE);

  /// Background colors
  static const Color background = Color(0xFFF7F7F7);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFE5E5E5);

  /// Border & Divider
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEEEEEE);

  // ============ GAME UI COLORS ============
  /// Card shadow (Duolingo-style bottom border)
  static const Color cardShadow = Color(0xFFE5E5E5);
  
  /// Button shadow colors
  static const Color buttonShadowBlue = primaryDark;
  static const Color buttonShadowGreen = greenDark;
  static const Color buttonShadowOrange = orangeDark;
  static const Color buttonShadowPurple = purpleDark;

  // ============ GRADIENT PRESETS ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [green, greenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [orange, orangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, purpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ HELPER METHODS ============
  /// Lấy màu với opacity (thay thế withOpacity deprecated)
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Shadow cho card style Duolingo
  static List<BoxShadow> cardBoxShadow({Color? color, double offset = 4}) {
    return [
      BoxShadow(
        color: color ?? cardShadow,
        offset: Offset(0, offset),
        blurRadius: 0,
      ),
    ];
  }

  /// Shadow cho button style Duolingo
  static List<BoxShadow> buttonBoxShadow(Color shadowColor, {double offset = 6}) {
    return [
      BoxShadow(
        color: shadowColor,
        offset: Offset(0, offset),
        blurRadius: 0,
      ),
    ];
  }

  /// Glow effect cho decorations
  static List<BoxShadow> glowEffect(Color color, {double blur = 8, double spread = 2}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }
}
