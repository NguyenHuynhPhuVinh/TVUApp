import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// TVU Mascot - Nhân vật linh vật của app
enum TVUMascotMood { happy, excited, thinking, sad, studying }
enum TVUMascotSize { sm, md, lg, xl }

class TVUMascot extends StatelessWidget {
  final TVUMascotMood mood;
  final TVUMascotSize size;
  final Color? color;
  final bool hasGlow;
  final bool hasAnimation;
  final bool hasHat;
  final Color? hatAccentColor;

  const TVUMascot({
    super.key,
    this.mood = TVUMascotMood.happy,
    this.size = TVUMascotSize.lg,
    this.color,
    this.hasGlow = true,
    this.hasAnimation = true,
    this.hasHat = true,
    this.hatAccentColor,
  });

  double get _size {
    switch (size) {
      case TVUMascotSize.sm:
        return 60.w;
      case TVUMascotSize.md:
        return 80.w;
      case TVUMascotSize.lg:
        return 120.w;
      case TVUMascotSize.xl:
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
  double get _accessorySize => _size * 0.15;

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
      clipBehavior: Clip.none,
      children: [
        // Glow effect
        if (hasGlow) _buildGlow(),
        // Main body
        _buildBody(),
        // Hat
        if (hasHat) _buildGraduationHat(),
        // Mood accessories
        _buildMoodAccessory(),
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

    return SizedBox(
      width: _glowSize + 20.w,
      height: _glowSize + (_hasHat ? _hatHeight : 0) + 20.h,
      child: Center(child: mascot),
    );
  }

  bool get _hasHat => hasHat;

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
      child: Stack(
        children: [
          // Pupil
          Align(
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
          // Eye shine
          Positioned(
            top: _eyeHeight * 0.15,
            left: _eyeWidth * 0.2,
            child: Container(
              width: _pupilWidth * 0.4,
              height: _pupilWidth * 0.4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _getEyeAlignment() {
    switch (mood) {
      case TVUMascotMood.happy:
      case TVUMascotMood.excited:
        return Alignment.bottomCenter;
      case TVUMascotMood.thinking:
        return const Alignment(0.5, 0.5);
      case TVUMascotMood.sad:
        return Alignment.center;
      case TVUMascotMood.studying:
        return const Alignment(0, 0.3);
    }
  }

  Widget _buildMouth() {
    switch (mood) {
      case TVUMascotMood.happy:
      case TVUMascotMood.excited:
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
      case TVUMascotMood.thinking:
        return Container(
          width: _smileWidth * 0.5,
          height: _smileHeight * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_smileWidth / 4),
          ),
        );
      case TVUMascotMood.sad:
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
      case TVUMascotMood.studying:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _smileWidth * 0.6,
              height: _smileHeight * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_smileWidth / 4),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildGraduationHat() {
    final accentColor = hatAccentColor ?? AppColors.orange;

    return Positioned(
      top: -_hatHeight * 0.3,
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
            // Top of hat
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
            // Tassel
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
            // Hat button
            Positioned(
              top: -_hatHeight * 0.35,
              left: _hatWidth * 0.35,
              child: Container(
                width: _hatWidth * 0.3,
                height: _hatWidth * 0.15,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 500.ms)
          .slideY(begin: -0.5, end: 0, duration: 400.ms),
    );
  }

  Widget _buildMoodAccessory() {
    switch (mood) {
      case TVUMascotMood.excited:
        // Stars around
        return Positioned(
          top: -_size * 0.1,
          right: -_size * 0.15,
          child: Icon(
            Iconsax.star1,
            color: AppColors.yellow,
            size: _accessorySize,
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 500.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(0.8, 0.8),
                duration: 500.ms,
              ),
        );
      case TVUMascotMood.thinking:
        // Thought bubble
        return Positioned(
          top: -_size * 0.2,
          right: -_size * 0.3,
          child: Icon(
            Iconsax.message_question,
            color: AppColors.purple,
            size: _accessorySize * 1.2,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -5, duration: 1000.ms),
        );
      case TVUMascotMood.studying:
        // Book icon
        return Positioned(
          bottom: -_size * 0.1,
          right: -_size * 0.2,
          child: Icon(
            Iconsax.book_1,
            color: AppColors.green,
            size: _accessorySize * 1.3,
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideX(begin: 0.5, end: 0),
        );
      case TVUMascotMood.sad:
        // Tear drop
        return Positioned(
          bottom: _size * 0.25,
          left: _size * 0.15,
          child: Icon(
            Icons.water_drop,
            color: AppColors.primary,
            size: _accessorySize * 0.6,
          )
              .animate(onPlay: (c) => c.repeat())
              .moveY(begin: 0, end: 10, duration: 800.ms)
              .fadeOut(delay: 600.ms, duration: 200.ms),
        );
      case TVUMascotMood.happy:
        return const SizedBox.shrink();
    }
  }
}

/// Simple TVU Logo Mascot (chỉ có icon, không có mặt)
class TVULogoMascot extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool hasAnimation;
  final bool hasShadow;

  const TVULogoMascot({
    super.key,
    this.size = 120,
    this.backgroundColor,
    this.iconColor,
    this.hasAnimation = true,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: hasShadow
            ? AppColors.buttonBoxShadow(AppColors.primaryDark)
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: size * 0.6,
          color: iconColor ?? AppColors.primary,
        ),
      ),
    );

    if (hasAnimation) {
      logo = logo
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .shimmer(duration: 2000.ms, color: AppColors.withAlpha(Colors.white, 0.3));
    }

    return logo;
  }
}
