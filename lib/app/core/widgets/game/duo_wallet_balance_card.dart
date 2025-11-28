import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/number_formatter.dart';

/// Card hiển thị ví như thẻ ngân hàng thật
class DuoWalletBalanceCard extends StatelessWidget {
  final int virtualBalance;
  final int diamonds;
  final int coins;
  final String? cardHolder;

  const DuoWalletBalanceCard({
    super.key,
    required this.virtualBalance,
    required this.diamonds,
    required this.coins,
    this.cardHolder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppStyles.rounded2xl,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pattern decoration
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Card content
          Padding(
            padding: EdgeInsets.all(AppStyles.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Logo & Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/game/currency/cash_green_cash_1st_64px.png',
                          width: 32.w,
                          height: 32.w,
                        ),
                        SizedBox(width: AppStyles.space2),
                        Text(
                          'TVUCash',
                          style: TextStyle(
                            fontSize: AppStyles.textLg,
                            fontWeight: AppStyles.fontBold,
                            color: AppColors.backgroundWhite,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    // Chip icon
                    Container(
                      width: 40.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700),
                            const Color(0xFFFFA500),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CustomPaint(
                        painter: _ChipPainter(),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppStyles.space5),
                
                // Balance
                Text(
                  'Số dư khả dụng',
                  style: TextStyle(
                    fontSize: AppStyles.textXs,
                    color: AppColors.backgroundWhite.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: AppStyles.space1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormatter.withCommas(virtualBalance),
                      style: TextStyle(
                        fontSize: AppStyles.text3xl,
                        fontWeight: AppStyles.fontBold,
                        color: AppColors.backgroundWhite,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: AppStyles.space2),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        'TC',
                        style: TextStyle(
                          fontSize: AppStyles.textSm,
                          fontWeight: AppStyles.fontSemibold,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppStyles.space5),
                
                // Card holder
                if (cardHolder != null) ...[
                  Text(
                    'CHỦ THẺ',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.backgroundWhite.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    cardHolder!.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      fontWeight: AppStyles.fontSemibold,
                      color: AppColors.backgroundWhite,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: AppStyles.space4),
                ],
                
                // Mini balances
                Row(
                  children: [
                    Expanded(child: _DuoMiniBalance(
                      icon: 'assets/game/currency/diamond_blue_diamond_1st_64px.png',
                      label: 'Diamond',
                      value: diamonds,
                      color: AppColors.primary,
                    )),
                    SizedBox(width: AppStyles.space3),
                    Expanded(child: _DuoMiniBalance(
                      icon: 'assets/game/currency/coin_golden_coin_1st_64px.png',
                      label: 'Coin',
                      value: coins,
                      color: AppColors.yellow,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DuoMiniBalance extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final Color color;

  const _DuoMiniBalance({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppStyles.space3,
        vertical: AppStyles.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.1),
        borderRadius: AppStyles.roundedLg,
        border: Border.all(
          color: AppColors.backgroundWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 20.w, height: 20.w),
          SizedBox(width: AppStyles.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.backgroundWhite.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  NumberFormatter.compact(value),
                  style: TextStyle(
                    fontSize: AppStyles.textSm,
                    fontWeight: AppStyles.fontBold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter cho chip thẻ
class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8860B).withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vẽ các đường ngang
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        paint,
      );
    }
    
    // Vẽ đường dọc giữa
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
