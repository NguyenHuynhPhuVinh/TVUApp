import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Widget hiển thị nhóm môn theo học lực (có thể expand/collapse)
class DuoGradeCategory extends StatefulWidget {
  final String title;
  final int count;
  final List<DuoGradeCategoryItem> items;
  final Color color;
  final bool initialExpanded;

  const DuoGradeCategory({
    super.key,
    required this.title,
    required this.count,
    required this.items,
    required this.color,
    this.initialExpanded = false,
  });

  @override
  State<DuoGradeCategory> createState() => _DuoGradeCategoryState();
}

class _DuoGradeCategoryState extends State<DuoGradeCategory>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
    _controller = AnimationController(
      duration: AppStyles.durationNormal,
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_expanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.space3),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: AppColors.cardBoxShadow(),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _toggle,
            borderRadius: AppStyles.roundedXl,
            child: Padding(
              padding: EdgeInsets.all(AppStyles.space4),
              child: Row(
                children: [
                  // Color indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: AppStyles.roundedFull,
                    ),
                  ),
                  SizedBox(width: AppStyles.space3),
                  // Title & count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: AppStyles.textBase,
                            fontWeight: AppStyles.fontSemibold,
                            color: widget.color,
                          ),
                        ),
                        Text(
                          '${widget.count} môn học',
                          style: TextStyle(
                            fontSize: AppStyles.textXs,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand icon
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Iconsax.arrow_down_1,
                      color: widget.color,
                      size: AppStyles.iconMd,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildContent(),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: AppStyles.durationNormal,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.only(
        left: AppStyles.space4,
        right: AppStyles.space4,
        bottom: AppStyles.space4,
      ),
      child: Column(
        children: widget.items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppStyles.space2),
            child: _DuoGradeItemTile(
              subject: item.subject,
              score: item.score,
              letterGrade: item.letterGrade,
              color: widget.color,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data class cho item trong category
class DuoGradeCategoryItem {
  final String subject;
  final String score;
  final String letterGrade;

  const DuoGradeCategoryItem({
    required this.subject,
    required this.score,
    required this.letterGrade,
  });
}

/// Tile hiển thị một môn học trong category
class _DuoGradeItemTile extends StatelessWidget {
  final String subject;
  final String score;
  final String letterGrade;
  final Color color;

  const _DuoGradeItemTile({
    required this.subject,
    required this.score,
    required this.letterGrade,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space3,
        vertical: AppStyles.space3,
      ),
      decoration: BoxDecoration(
        color: AppColors.withAlpha(color, 0.05),
        borderRadius: AppStyles.roundedLg,
        border: Border.all(color: AppColors.withAlpha(color, 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subject,
              style: TextStyle(
                fontSize: AppStyles.textSm,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppStyles.space3),
          // Score badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppStyles.space3,
              vertical: AppStyles.space1,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppStyles.roundedMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score,
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    fontWeight: AppStyles.fontBold,
                    color: Colors.white,
                  ),
                ),
                if (letterGrade.isNotEmpty) ...[
                  SizedBox(width: AppStyles.space1),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.withAlpha(Colors.white, 0.3),
                      borderRadius: AppStyles.roundedSm,
                    ),
                    child: Text(
                      letterGrade,
                      style: TextStyle(
                        fontSize: AppStyles.textXs,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
