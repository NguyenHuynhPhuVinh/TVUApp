import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.h),
              _buildHeader(),
              SizedBox(height: 48.h),
              _buildLoginForm(),
              SizedBox(height: 24.h),
              _buildLoginButton(),
              SizedBox(height: 16.h),
              _buildErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(
            Icons.school_rounded,
            size: 56.sp,
            color: Get.theme.primaryColor,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'TVUApp',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Get.theme.primaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Đăng nhập bằng tài khoản sinh viên',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: controller.usernameController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Mã số sinh viên',
            hintText: 'Nhập MSSV',
            prefixIcon: const Icon(Iconsax.user),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => TextField(
          controller: controller.passwordController,
          obscureText: !controller.isPasswordVisible.value,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            hintText: 'Nhập mật khẩu',
            prefixIcon: const Icon(Iconsax.lock),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Iconsax.eye
                    : Iconsax.eye_slash,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        child: controller.isLoading.value
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    ));
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Iconsax.warning_2, color: Colors.red[700], size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(color: Colors.red[700], fontSize: 14.sp),
              ),
            ),
          ],
        ),
      );
    });
  }
}
