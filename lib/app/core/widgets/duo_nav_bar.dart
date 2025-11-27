import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

/// Duolingo-style Bottom Navigation Bar
/// Simple, clean với icon lớn và indicator bar phía dưới
class DuoNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DuoNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const DuoNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: AppStyles.space2),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: _DuoNavItem(
                  item: item,
                  isActive: isActive,
                  activeColor: activeColor ?? AppColors.primary,
                  inactiveColor: inactiveColor ?? AppColors.textTertiary,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DuoNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const DuoNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _DuoNavItem extends StatefulWidget {
  final DuoNavItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _DuoNavItem({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  State<_DuoNavItem> createState() => _DuoNavItemState();
}

class _DuoNavItemState extends State<_DuoNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isActive ? (widget.item.activeIcon ?? widget.item.icon) : widget.item.icon,
                color: widget.isActive ? widget.activeColor : widget.inactiveColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 4.h),
            // Label
            Text(
              widget.item.label,
              style: TextStyle(
                color: widget.isActive ? widget.activeColor : widget.inactiveColor,
                fontSize: 11.sp,
                fontWeight: widget.isActive ? AppStyles.fontBold : AppStyles.fontMedium,
              ),
            ),
            SizedBox(height: 4.h),
            // Active indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isActive ? 32.w : 0,
              height: 4.h,
              decoration: BoxDecoration(
                color: widget.isActive ? widget.activeColor : Colors.transparent,
                borderRadius: AppStyles.roundedFull,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
