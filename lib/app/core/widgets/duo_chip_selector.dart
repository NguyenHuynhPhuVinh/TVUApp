import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Horizontal Chip Selector (cho week selector, filter, etc.)
class DuoChipSelector<T> extends StatelessWidget {
  final List<DuoChipItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T>? onSelected;
  final double height;
  final Color? activeColor;

  const DuoChipSelector({
    super.key,
    required this.items,
    this.selectedValue,
    this.onSelected,
    this.height = 44,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (height + 6).h, // Extra space for shadow
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.only(
          left: AppStyles.space4,
          right: AppStyles.space4,
          bottom: 4.h, // Space for shadow
        ),
        itemCount: items.length,
        separatorBuilder: (_, i) => SizedBox(width: AppStyles.space2),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.value == selectedValue;
          return _DuoChip(
            item: item,
            isSelected: isSelected,
            activeColor: activeColor ?? AppColors.primary,
            onTap: () => onSelected?.call(item.value),
          );
        },
      ),
    );
  }
}

class DuoChipItem<T> {
  final T value;
  final String label;
  final bool hasContent;
  final IconData? icon;

  const DuoChipItem({
    required this.value,
    required this.label,
    this.hasContent = false,
    this.icon,
  });
}

class _DuoChip<T> extends StatefulWidget {
  final DuoChipItem<T> item;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _DuoChip({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_DuoChip<T>> createState() => _DuoChipState<T>();
}

class _DuoChipState<T> extends State<_DuoChip<T>> {
  bool _isPressed = false;

  Color get _bgColor {
    if (widget.isSelected) return widget.activeColor;
    if (widget.item.hasContent) return AppColors.primarySoft;
    return AppColors.backgroundDark;
  }

  Color get _textColor {
    if (widget.isSelected) return Colors.white;
    if (widget.item.hasContent) return widget.activeColor;
    return AppColors.textSecondary;
  }

  Color get _shadowColor {
    if (widget.isSelected) {
      if (widget.activeColor == AppColors.primary) return AppColors.primaryDark;
      if (widget.activeColor == AppColors.green) return AppColors.greenDark;
      if (widget.activeColor == AppColors.orange) return AppColors.orangeDark;
      return AppColors.primaryDark;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppStyles.durationFast,
        padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space2),
        transform: Matrix4.translationValues(0, _isPressed && widget.isSelected ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: AppStyles.roundedFull,
          border: widget.item.hasContent && !widget.isSelected
              ? Border.all(color: AppColors.withAlpha(widget.activeColor, 0.3), width: 1.5)
              : null,
          boxShadow: widget.isSelected && !_isPressed
              ? [
                  BoxShadow(
                    color: _shadowColor,
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.item.icon != null) ...[
              Icon(widget.item.icon, color: _textColor, size: AppStyles.iconXs),
              SizedBox(width: AppStyles.space1),
            ],
            Text(
              widget.item.label,
              style: TextStyle(
                color: _textColor,
                fontSize: AppStyles.textSm,
                fontWeight: widget.isSelected || widget.item.hasContent
                    ? AppStyles.fontBold
                    : AppStyles.fontMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Duolingo-style Day Header Badge
class DuoDayBadge extends StatelessWidget {
  final String day;
  final Color? color;

  const DuoDayBadge({
    super.key,
    required this.day,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.space4, vertical: AppStyles.space2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppStyles.roundedLg,
        boxShadow: [
          BoxShadow(
            color: bgColor == AppColors.primary
                ? AppColors.primaryDark
                : AppColors.withAlpha(bgColor, 0.5),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        day,
        style: TextStyle(
          color: Colors.white,
          fontSize: AppStyles.textSm,
          fontWeight: AppStyles.fontBold,
        ),
      ),
    );
  }
}
