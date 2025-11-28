import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_card.dart';
import '../../../../features/gamification/shared/widgets/duo_game_stats_bar.dart';

/// Card chào mừng với thông tin user và game stats
class DuoWelcomeCard extends StatelessWidget {
  final String name;
  final String studentId;
  final int level;
  final int coins;
  final int diamonds;

  const DuoWelcomeCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.level,
    required this.coins,
    required this.diamonds,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      padding: EdgeInsets.all(AppStyles.space5),
      backgroundColor: AppColors.primary,
      shadowColor: AppColors.primaryDark,
      shadowOffset: AppStyles.shadowLg,
      hasBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppStyles.avatarLg,
                height: AppStyles.avatarLg,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryLight,
                    width: AppStyles.border3,
                  ),
                ),
                child: Icon(
                  Iconsax.user,
                  color: AppColors.primary,
                  size: AppStyles.iconLg,
                ),
              ),
              SizedBox(width: AppStyles.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Xin chào!' : name,
                      style: TextStyle(
                        fontSize: AppStyles.textLg,
                        fontWeight: AppStyles.fontBold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppStyles.space1),
                    Text(
                      studentId.isEmpty ? 'Đang tải...' : 'MSSV: $studentId',
                      style: TextStyle(
                        fontSize: AppStyles.textSm,
                        color: AppColors.withAlpha(Colors.white, 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppStyles.space4),
          DuoGameStatsBar(
            level: level,
            coins: coins,
            diamonds: diamonds,
          ),
        ],
      ),
    );
  }
}
