import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Extension methods cho Animation - chuẩn hóa animation toàn app
/// Giảm code lặp lại trong các View
extension DuoAnimateExtension on Widget {
  /// Fade in + slide up animation (dùng nhiều nhất)
  /// [delay] - delay trước khi bắt đầu animation (ms)
  /// [slideBegin] - vị trí bắt đầu slide (0.1 = 10% từ dưới lên)
  Widget animateFadeSlide({
    double delay = 0,
    double slideBegin = 0.1,
    int duration = 400,
  }) {
    return animate()
        .fadeIn(duration: duration.ms, delay: delay.ms)
        .slideY(
          begin: slideBegin,
          end: 0,
          duration: duration.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }

  /// Fade in + slide from left
  Widget animateFadeSlideLeft({
    double delay = 0,
    double slideBegin = -0.2,
    int duration = 400,
  }) {
    return animate()
        .fadeIn(duration: duration.ms, delay: delay.ms)
        .slideX(
          begin: slideBegin,
          end: 0,
          duration: duration.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }

  /// Fade in + slide from right
  Widget animateFadeSlideRight({
    double delay = 0,
    double slideBegin = 0.2,
    int duration = 400,
  }) {
    return animate()
        .fadeIn(duration: duration.ms, delay: delay.ms)
        .slideX(
          begin: slideBegin,
          end: 0,
          duration: duration.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        );
  }

  /// Scale + fade animation (dùng cho reward cards)
  Widget animateScaleFade({
    double delay = 0,
    double scaleBegin = 0.8,
    int duration = 400,
  }) {
    return animate()
        .scale(
          begin: Offset(scaleBegin, scaleBegin),
          end: const Offset(1, 1),
          duration: duration.ms,
          delay: delay.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: (duration * 0.75).toInt().ms, delay: delay.ms);
  }

  /// Bounce scale animation (dùng cho buttons, icons)
  Widget animateBounce({
    double delay = 0,
    double scaleBegin = 0.5,
    int duration = 600,
  }) {
    return animate().scale(
      begin: Offset(scaleBegin, scaleBegin),
      end: const Offset(1, 1),
      duration: duration.ms,
      delay: delay.ms,
      curve: Curves.elasticOut,
    );
  }

  /// Pulse animation (lặp vô hạn - dùng cho icons, badges)
  Widget animatePulse({
    double scaleEnd = 1.1,
    int duration = 1000,
  }) {
    return animate(onPlay: (c) => c.repeat(reverse: true)).scale(
      begin: const Offset(1, 1),
      end: Offset(scaleEnd, scaleEnd),
      duration: duration.ms,
      curve: Curves.easeInOut,
    );
  }

  /// Shake animation (dùng cho error states)
  Widget animateShake({
    double offset = 10,
    int duration = 500,
  }) {
    return animate()
        .shake(
          hz: 4,
          offset: Offset(offset, 0),
          duration: duration.ms,
        )
        .then()
        .shake(
          hz: 2,
          offset: Offset(offset / 2, 0),
          duration: (duration / 2).toInt().ms,
        );
  }

  /// Rotate animation (lặp - dùng cho loading icons)
  Widget animateRotate({
    double begin = -0.05,
    double end = 0.05,
    int duration = 500,
  }) {
    return animate(onPlay: (c) => c.repeat(reverse: true)).rotate(
      begin: begin,
      end: end,
      duration: duration.ms,
    );
  }

  /// Staggered list item animation
  /// [index] - vị trí trong list để tính delay
  /// [baseDelay] - delay cơ bản (ms)
  /// [staggerDelay] - delay giữa các item (ms)
  Widget animateListItem({
    required int index,
    int baseDelay = 0,
    int staggerDelay = 50,
    int duration = 400,
  }) {
    final delay = baseDelay + (index * staggerDelay);
    return animateFadeSlide(delay: delay.toDouble(), duration: duration);
  }
}

/// Extension cho List<Widget> - animate cả list
extension DuoAnimateListExtension on List<Widget> {
  /// Animate tất cả items trong list với stagger effect
  List<Widget> animateStaggered({
    int baseDelay = 0,
    int staggerDelay = 50,
    int duration = 400,
  }) {
    return asMap().entries.map((entry) {
      return entry.value.animateListItem(
        index: entry.key,
        baseDelay: baseDelay,
        staggerDelay: staggerDelay,
        duration: duration,
      );
    }).toList();
  }
}
