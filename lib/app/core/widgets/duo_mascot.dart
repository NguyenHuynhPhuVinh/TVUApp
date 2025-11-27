import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Mascot Widget
enum DuoMascotMood { happy, excited, thinking, sad }
enum DuoMascotSize { sm, md, lg, xl }

class DuoMascot extends StatelessWidget {
  final DuoMascotMood mood;
  final DuoMascotSize size;
  final Color? color;
  final bool hasGlow;
  final bool hasAnimation;
  final bool hasHat;
  final Color? hatAccentColor;

  const DuoMascot({
    super.key,
    this.mood = DuoMascotMood.happy,
    this.size = DuoMascotSize.lg,
    this.color,
    this.hasGlow = true,
    this.hasAnimation = true,
    this.hasHat = true,
    this.hatAccentColor,
  });

  double get _size {
    switch (size) {
      case DuoMascotSize.sm:
        return 60.w;
      case DuoMascotSize.md:
        return 80.w;
      case DuoMascotSize.lg:
        return 120.w;
      case DuoMascotSize.xl:
        return 160.w;
    }
  }

  double get _glowSize => _size * 1.2;
  double get _eyeWidth => _size * 0.16;
  double get _eyeHeight => _size * 0.2;
  double get _pupilWidth => _size * 0.1;
  double get _pupilHeight => _size * 0.12;
  double get _smileWidth => _size * 0.33;
  double get _smileHeight => _size * 0.16;
  double get _hatWidth => _size * 0.5;
  double get _hatHeight => _size * 0.25;

  Color get _mainColor => color ?? AppColors.primary;
  Color get _darkColor {
    if (color == AppColors.green) return AppColors.greenDark;
    if (color == AppColors.orange) return AppColors.orangeDark;
    if (color == AppColors.purple) return AppColors.purpleDark;
    return AppColors.primaryDark;
  }

  @override
  Widget build(BuildContext context) {
    Widget mascot = Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (hasGlow) _buildGlow(),
        // Main body
        _buildBody(),
        // Hat
        if (hasHat) _buildHat(),
      ],
    );

    if (hasAnimation) {
      mascot = mascot
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 800.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -5, duration: 1500.ms, curve: Curves.easeInOut);
    }

    return mascot;
  }

  Widget _buildGlow() {
    return Container(
      width: _glowSize,
      height: _glowSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppColors.glowEffect(_mainColor, blur: 30, spread: 10),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildBody() {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: _mainColor,
        shape: BoxShape.circle,
        border: Border.all(color: _darkColor, width: AppStyles.border4),
        boxShadow: AppColors.buttonBoxShadow(_darkColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Eyes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEye(isLeft: true),
              SizedBox(width: _size * 0.13),
              _buildEye(isLeft: false),
            ],
          ),
          SizedBox(height: _size * 0.06),
          // Mouth
          _buildMouth(),
        ],
      ),
    );
  }

  Widget _buildEye({required bool isLeft}) {
    return Container(
      width: _eyeWidth,
      height: _eyeHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_eyeWidth / 2),
      ),
      child: Align(
        alignment: _getEyeAlignment(),
        child: Container(
          width: _pupilWidth,
          height: _pupilHeight,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(_pupilWidth / 2),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scaleY(begin: 1, end: 0.1, duration: 150.ms, delay: 3000.ms)
            .then()
            .scaleY(begin: 0.1, end: 1, duration: 150.ms),
      ),
    );
  }

  Alignment _getEyeAlignment() {
    switch (mood) {
      case DuoMascotMood.happy:
      case DuoMascotMood.excited:
        return Alignment.bottomCenter;
      case DuoMascotMood.thinking:
        return const Alignment(0.5, 0.5);
      case DuoMascotMood.sad:
        return Alignment.center;
    }
  }

  Widget _buildMouth() {
    switch (mood) {
      case DuoMascotMood.happy:
      case DuoMascotMood.excited:
        return Container(
          width: _smileWidth,
          height: _smileHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_smileWidth / 2),
              bottomRight: Radius.circular(_smileWidth / 2),
            ),
          ),
        );
      case DuoMascotMood.thinking:
        return Container(
          width: _smileWidth * 0.5,
          height: _smileHeight * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_smileWidth / 4),
          ),
        );
      case DuoMascotMood.sad:
        return Container(
          width: _smileWidth,
          height: _smileHeight * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_smileWidth / 2),
              topRight: Radius.circular(_smileWidth / 2),
            ),
          ),
        );
    }
  }

  Widget _buildHat() {
    final accentColor = hatAccentColor ?? AppColors.orange;

    return Positioned(
      top: 0,
      child: Container(
        width: _hatWidth,
        height: _hatHeight,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppStyles.radiusSm),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -_hatHeight * 0.3,
              left: 0,
              right: 0,
              child: Container(
                height: _hatHeight * 0.4,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm / 2),
                ),
              ),
            ),
            Positioned(
              top: -_hatHeight * 0.4,
              right: -_hatWidth * 0.08,
              child: Container(
                width: _hatWidth * 0.13,
                height: _hatHeight * 0.65,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .rotate(begin: -0.1, end: 0.1, duration: 800.ms),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideY(begin: -0.5, end: 0, duration: 400.ms),
    );
  }
}
