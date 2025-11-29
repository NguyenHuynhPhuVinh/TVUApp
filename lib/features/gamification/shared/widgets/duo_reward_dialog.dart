import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/components/widgets.dart';

/// Model cho custom reward item
class RewardItem {
  final String icon;
  final String label;
  final int value;
  final Color color;

  const RewardItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Dialog hiển thị phần thưởng - dùng chung cho toàn bộ hệ thống
/// Hỗ trợ: check-in, mailbox, reward code, achievements, shop...
class DuoRewardDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<RewardItem> rewards;
  final bool leveledUp;
  final int? newLevel;
  final String? iconAsset;
  final Color? glowColor;
  final DuoButtonVariant buttonVariant;
  final String buttonText;

  const DuoRewardDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.rewards,
    this.leveledUp = false,
    this.newLevel,
    this.iconAsset,
    this.glowColor,
    this.buttonVariant = DuoButtonVariant.warning,
    this.buttonText = 'Tuyệt vời!',
  });

  // ============ STATIC METHODS ============

  /// Show dialog cơ bản với coins, diamonds, xp
  static Future<void> show({
    required String title,
    String? subtitle,
    required int coins,
    required int diamonds,
    required int xp,
    bool leveledUp = false,
    int? newLevel,
    String? iconAsset,
    Color? glowColor,
  }) async {
    final rewards = <RewardItem>[];
    if (coins > 0) {
      rewards.add(RewardItem(
        icon: AppAssets.coin,
        label: 'Xu',
        value: coins,
        color: AppColors.yellow,
      ));
    }
    if (diamonds > 0) {
      rewards.add(RewardItem(
        icon: AppAssets.diamond,
        label: 'Kim cương',
        value: diamonds,
        color: AppColors.primary,
      ));
    }
    if (xp > 0) {
      rewards.add(RewardItem(
        icon: AppAssets.xpStar,
        label: 'XP',
        value: xp,
        color: AppColors.purple,
      ));
    }

    await Get.dialog(
      DuoRewardDialog(
        title: title,
        subtitle: subtitle,
        rewards: rewards,
        leveledUp: leveledUp,
        newLevel: newLevel,
        iconAsset: iconAsset,
        glowColor: glowColor,
      ),
      barrierDismissible: true,
    );
  }

  /// Show dialog cho check-in điểm danh
  static Future<void> showCheckIn({
    required String tenMon,
    required Map<String, dynamic> rewards,
  }) async {
    await show(
      title: 'Điểm danh thành công!',
      subtitle: tenMon,
      coins: rewards['earnedCoins'] ?? 0,
      diamonds: rewards['earnedDiamonds'] ?? 0,
      xp: rewards['earnedXp'] ?? 0,
      leveledUp: rewards['leveledUp'] == true,
      newLevel: rewards['newLevel'],
      iconAsset: AppAssets.checkmark,
      glowColor: AppColors.green,
    );
  }

  /// Show dialog cho nhận thưởng môn học CTDT
  static Future<void> showSubjectReward({
    required String tenMon,
    required Map<String, dynamic> rewards,
  }) async {
    await show(
      title: 'Nhận thưởng thành công!',
      subtitle: tenMon,
      coins: rewards['earnedCoins'] ?? 0,
      diamonds: rewards['earnedDiamonds'] ?? 0,
      xp: rewards['earnedXp'] ?? 0,
      leveledUp: rewards['leveledUp'] == true,
      newLevel: rewards['newLevel'],
      iconAsset: AppAssets.medalGold,
      glowColor: AppColors.yellow,
    );
  }

  /// Show dialog cho nhận nhiều thưởng môn học CTDT
  static Future<void> showBulkSubjectReward({
    required int count,
    required int totalCoins,
    required int totalDiamonds,
    required int totalXp,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await show(
      title: 'Nhận thưởng thành công!',
      subtitle: 'Đã nhận $count môn học',
      coins: totalCoins,
      diamonds: totalDiamonds,
      xp: totalXp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      iconAsset: AppAssets.medalGold,
      glowColor: AppColors.yellow,
    );
  }

  /// Show dialog cho nhận quà từ mailbox
  static Future<void> showMailReward({
    required String mailTitle,
    required int coins,
    required int diamonds,
    required int xp,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await show(
      title: 'Nhận quà thành công!',
      subtitle: mailTitle,
      coins: coins,
      diamonds: diamonds,
      xp: xp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      iconAsset: AppAssets.chest,
      glowColor: AppColors.yellow,
    );
  }

  /// Show dialog cho nhận nhiều quà từ mailbox
  static Future<void> showBulkMailReward({
    required int count,
    required int totalCoins,
    required int totalDiamonds,
    required int totalXp,
  }) async {
    await show(
      title: 'Nhận quà thành công!',
      subtitle: 'Đã nhận $count phần quà',
      coins: totalCoins,
      diamonds: totalDiamonds,
      xp: totalXp,
      iconAsset: AppAssets.chest,
      glowColor: AppColors.yellow,
    );
  }

  /// Show dialog cho nhận mã thưởng
  static Future<void> showRewardCode({
    required int coins,
    required int diamonds,
    required int xp,
  }) async {
    await show(
      title: 'Nhận mã thành công!',
      subtitle: 'Bạn đã nhận được phần thưởng',
      coins: coins,
      diamonds: diamonds,
      xp: xp,
      iconAsset: AppAssets.giftPurple,
      glowColor: AppColors.green,
    );
  }

  /// Show dialog cho nhận thưởng thành tựu
  static Future<void> showAchievementReward({
    required String achievementName,
    required int coins,
    required int diamonds,
    required int xp,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await show(
      title: 'Nhận thưởng thành công!',
      subtitle: achievementName,
      coins: coins,
      diamonds: diamonds,
      xp: xp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      iconAsset: AppAssets.crown,
      glowColor: AppColors.purple,
    );
  }

  /// Show dialog cho nhận nhiều thưởng thành tựu
  static Future<void> showBulkAchievementReward({
    required int count,
    required int totalCoins,
    required int totalDiamonds,
    required int totalXp,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await show(
      title: 'Nhận thưởng thành công!',
      subtitle: 'Đã nhận $count thành tựu',
      coins: totalCoins,
      diamonds: totalDiamonds,
      xp: totalXp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      iconAsset: AppAssets.crown,
      glowColor: AppColors.purple,
    );
  }

  /// Show dialog cho nhận thưởng rank
  static Future<void> showRankReward({
    required String rankName,
    required int coins,
    required int diamonds,
    required int xp,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await show(
      title: 'Nhận thưởng Rank!',
      subtitle: rankName,
      coins: coins,
      diamonds: diamonds,
      xp: xp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      iconAsset: AppAssets.medalGold,
      glowColor: AppColors.purple,
    );
  }

  /// Show dialog cho nhận nhiều thưởng rank
  static Future<void> showBulkRankReward({
    required int count,
    required int totalCoins,
    required int totalDiamonds,
    required int totalXp,
    bool leveledUp = false,
    int? newLevel,
  }) async {
    await show(
      title: 'Nhận tất cả thưởng!',
      subtitle: '$count rank',
      coins: totalCoins,
      diamonds: totalDiamonds,
      xp: totalXp,
      leveledUp: leveledUp,
      newLevel: newLevel,
      iconAsset: AppAssets.medalGold,
      glowColor: AppColors.purple,
    );
  }

  /// Show dialog cho nhận thưởng học phí (TVUCash)
  static Future<void> showTuitionBonus({
    required int virtualBalance,
    String? semesterName,
  }) async {
    await Get.dialog(
      DuoRewardDialog(
        title: 'Nhận thưởng thành công!',
        subtitle: semesterName,
        rewards: [
          RewardItem(
            icon: AppAssets.tvuCash,
            label: 'TVUCash',
            value: virtualBalance,
            color: AppColors.green,
          ),
        ],
        iconAsset: AppAssets.tvuCash,
        glowColor: AppColors.green,
      ),
      barrierDismissible: true,
    );
  }

  /// Show dialog với custom rewards (cho wallet, shop...)
  static Future<void> showCustom({
    required String title,
    required List<RewardItem> rewards,
    String? subtitle,
    bool leveledUp = false,
    int? newLevel,
    String? iconAsset,
    Color? glowColor,
  }) async {
    await Get.dialog(
      DuoRewardDialog(
        title: title,
        subtitle: subtitle,
        rewards: rewards,
        leveledUp: leveledUp,
        newLevel: newLevel,
        iconAsset: iconAsset,
        glowColor: glowColor,
      ),
      barrierDismissible: true,
    );
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppStyles.space5),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: AppStyles.rounded2xl,
          boxShadow: [
            BoxShadow(
              color: (glowColor ?? AppColors.yellow).withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(height: AppStyles.space4),
            _buildTitle(),
            SizedBox(height: AppStyles.space4),
            _buildRewardsSection(),
            if (leveledUp) ...[
              SizedBox(height: AppStyles.space3),
              _buildLevelUpBadge(),
            ],
            SizedBox(height: AppStyles.space5),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final effectiveGlowColor = glowColor ?? AppColors.yellow;
    final effectiveIconAsset = iconAsset ?? AppAssets.chest;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                effectiveGlowColor.withValues(alpha: 0.3),
                effectiveGlowColor.withValues(alpha: 0),
              ],
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                duration: 1500.ms,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1)),
        // Icon
        Container(
          padding: EdgeInsets.all(AppStyles.space4),
          decoration: BoxDecoration(
            color: effectiveGlowColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow:
                AppColors.cardBoxShadow(color: effectiveGlowColor, offset: 4),
          ),
          child: Image.asset(
            effectiveIconAsset,
            width: 48.w,
            height: 48.w,
            errorBuilder: (_, __, ___) => Icon(
              Icons.card_giftcard_rounded,
              size: 48.w,
              color: effectiveGlowColor,
            ),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppStyles.textXl,
            fontWeight: AppStyles.fontBold,
            color: glowColor ?? AppColors.yellow,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          SizedBox(height: AppStyles.space1),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ],
    );
  }

  Widget _buildRewardsSection() {
    if (rewards.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(AppStyles.space4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppStyles.roundedXl,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            'Phần thưởng',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppStyles.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rewards.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildRewardItem(
                item.icon,
                '+${_formatNumber(item.value)}',
                item.label,
                index * 100,
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildRewardItem(
      String asset, String value, String label, int delayMs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: AppStyles.roundedLg,
            boxShadow: AppColors.cardBoxShadow(offset: 2),
          ),
          child: Center(
            child: Image.asset(
              asset,
              width: 36.w,
              height: 36.w,
              errorBuilder: (_, __, ___) => Icon(
                Icons.star_rounded,
                size: 36.w,
                color: AppColors.yellow,
              ),
            ),
          ),
        )
            .animate()
            .scale(
                delay: Duration(milliseconds: 400 + delayMs),
                duration: 400.ms,
                curve: Curves.elasticOut),
        SizedBox(height: AppStyles.space2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppStyles.textLg,
            fontWeight: AppStyles.fontBold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 500 + delayMs)),
        Text(
          label,
          style: TextStyle(
            fontSize: AppStyles.textXs,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelUpBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space4,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: AppStyles.roundedFull,
        boxShadow: AppColors.buttonBoxShadow(AppColors.purpleDark, offset: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16.w),
          SizedBox(width: AppStyles.space1),
          Text(
            'Level Up! Lv.$newLevel',
            style: TextStyle(
              fontSize: AppStyles.textSm,
              fontWeight: AppStyles.fontBold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildCloseButton() {
    return Builder(
      builder: (context) => DuoButton(
        text: buttonText,
        variant: buttonVariant,
        onPressed: () => Navigator.of(context).pop(),
        fullWidth: true,
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  String _formatNumber(int number) {
    return NumberFormatter.compact(number);
  }
}
