import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../base/duo_button.dart';

/// Bottom sheet hiển thị điều khoản sử dụng
class DuoTermsDialog extends StatelessWidget {
  const DuoTermsDialog({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const DuoTermsDialog(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radius3xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppStyles.space5, 0, AppStyles.space5, AppStyles.space5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  SizedBox(height: AppStyles.space4),
                  Flexible(child: _buildContent()),
                  SizedBox(height: AppStyles.space4),
                  _buildCloseButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppStyles.space3),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: AppStyles.roundedFull,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppStyles.space2),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: AppStyles.roundedLg,
          ),
          child: Icon(Icons.policy_rounded, color: AppColors.primary, size: AppStyles.iconLg),
        ),
        SizedBox(width: AppStyles.space3),
        Expanded(
          child: Text(
            'Điều khoản sử dụng',
            style: TextStyle(
              fontSize: AppStyles.textXl,
              fontWeight: AppStyles.fontBold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            '1. Giới thiệu',
            'Ứng dụng TVU Student được phát triển nhằm hỗ trợ sinh viên Trường Đại học Trà Vinh '
            'trong việc tra cứu thông tin học tập một cách thuận tiện.',
          ),
          _buildSection(
            '2. Cam kết bảo mật',
            '• Chúng tôi KHÔNG thu thập, lưu trữ hay chia sẻ bất kỳ thông tin cá nhân nào của bạn.\n'
            '• Thông tin đăng nhập chỉ được sử dụng để xác thực với hệ thống của trường.\n'
            '• Dữ liệu được lưu trữ cục bộ trên thiết bị của bạn và không được gửi đến bất kỳ máy chủ bên thứ ba nào.\n'
            '• Ứng dụng không sử dụng cookie theo dõi hay công cụ phân tích người dùng.',
          ),
          _buildSection(
            '3. Quyền truy cập',
            'Ứng dụng chỉ yêu cầu quyền truy cập internet để kết nối với hệ thống đào tạo của trường. '
            'Không yêu cầu bất kỳ quyền truy cập nào khác trên thiết bị của bạn.',
          ),
          _buildSection(
            '4. Nguồn dữ liệu',
            'Tất cả thông tin hiển thị trong ứng dụng được lấy trực tiếp từ hệ thống đào tạo '
            'chính thức của Trường Đại học Trà Vinh.',
          ),
          _buildSection(
            '5. Miễn trừ trách nhiệm',
            '• Ứng dụng được cung cấp miễn phí và không có bất kỳ bảo đảm nào.\n'
            '• Chúng tôi không chịu trách nhiệm về tính chính xác của dữ liệu từ hệ thống trường.\n'
            '• Người dùng nên kiểm tra lại thông tin quan trọng trên cổng thông tin chính thức.',
          ),
          _buildSection(
            '6. Liên hệ',
            'Nếu có thắc mắc về điều khoản sử dụng, vui lòng liên hệ qua email hỗ trợ của ứng dụng.',
          ),
          SizedBox(height: AppStyles.space2),
          Container(
            padding: EdgeInsets.all(AppStyles.space3),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: AppStyles.roundedLg,
              border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.green, size: AppStyles.iconMd),
                SizedBox(width: AppStyles.space2),
                Expanded(
                  child: Text(
                    'Bằng việc sử dụng ứng dụng, bạn đồng ý với các điều khoản trên.',
                    style: TextStyle(
                      fontSize: AppStyles.textSm,
                      color: AppColors.greenDark,
                      fontWeight: AppStyles.fontMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppStyles.space4),
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
          ),
          SizedBox(height: AppStyles.space1),
          Text(
            content,
            style: TextStyle(
              fontSize: AppStyles.textSm,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return DuoButton(
      text: 'Đã hiểu',
      icon: Icons.check_rounded,
      variant: DuoButtonVariant.primary,
      size: DuoButtonSize.md,
      onPressed: () => Get.back(),
    );
  }
}
