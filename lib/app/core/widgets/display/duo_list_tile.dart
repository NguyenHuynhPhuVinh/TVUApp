import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

/// Duolingo-style List Tile với 3D card effect
class DuoListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool showAccentBar;

  const DuoListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
    this.showAccentBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space4),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.roundedXl,
          border: Border.all(color: AppColors.border, width: AppStyles.border2),
          boxShadow: AppColors.cardBoxShadow(),
        ),
        child: Row(
          children: [
            if (showAccentBar) ...[
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppStyles.roundedFull,
                ),
              ),
              SizedBox(width: AppStyles.space3),
            ],
            if (leading != null) ...[
              leading!,
              SizedBox(width: AppStyles.space3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontSemibold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppStyles.space1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: AppStyles.space3),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Duolingo-style Schedule Item
class DuoScheduleItem extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final String teacher;
  final int lessonCount;
  final Color? accentColor;
  final VoidCallback? onTap;

  const DuoScheduleItem({
    super.key,
    required this.subject,
    required this.time,
    required this.room,
    required this.teacher,
    this.lessonCount = 0,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space4),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.roundedXl,
          border: Border.all(color: AppColors.border, width: AppStyles.border2),
          boxShadow: AppColors.cardBoxShadow(),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppStyles.roundedFull,
              ),
            ),
            SizedBox(width: AppStyles.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: AppStyles.textBase,
                      fontWeight: AppStyles.fontSemibold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppStyles.space2),
                  _buildInfoRow(Icons.access_time_rounded, time),
                  SizedBox(height: AppStyles.space1),
                  _buildInfoRow(Icons.location_on_outlined, room),
                  SizedBox(height: AppStyles.space1),
                  _buildInfoRow(Icons.person_outline_rounded, teacher),
                ],
              ),
            ),
            if (lessonCount > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppStyles.space3,
                  vertical: AppStyles.space2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.withAlpha(color, 0.1),
                  borderRadius: AppStyles.roundedLg,
                ),
                child: Column(
                  children: [
                    Text(
                      '$lessonCount',
                      style: TextStyle(
                        fontSize: AppStyles.textXl,
                        fontWeight: AppStyles.fontBold,
                        color: color,
                      ),
                    ),
                    Text(
                      'tiết',
                      style: TextStyle(
                        fontSize: AppStyles.textXs,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: AppStyles.iconXs, color: AppColors.textTertiary),
        SizedBox(width: AppStyles.space2),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

