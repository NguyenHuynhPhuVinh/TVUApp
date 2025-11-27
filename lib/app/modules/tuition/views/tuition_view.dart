import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/tuition_controller.dart';

class TuitionView extends GetView<TuitionController> {
  const TuitionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học phí'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.loadTuition,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildSummaryCard(),
            Expanded(child: _buildTuitionList()),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor, Get.theme.primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Đã đóng',
                controller.formatCurrency(controller.totalPaid.value),
                Iconsax.tick_circle,
                Colors.greenAccent,
              ),
              _buildSummaryItem(
                'Còn nợ',
                controller.formatCurrency(controller.totalDebt.value),
                Iconsax.warning_2,
                controller.totalDebt.value > 0 ? Colors.redAccent : Colors.greenAccent,
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: iconColor),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.white70),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTuitionList() {
    return Obx(() {
      if (controller.tuitionList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.wallet, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                'Chưa có thông tin học phí',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.tuitionList.length,
        itemBuilder: (context, index) {
          final item = controller.tuitionList[index];
          return _buildTuitionCard(item);
        },
      );
    });
  }

  Widget _buildTuitionCard(Map<String, dynamic> item) {
    final tuition = (item['hoc_phi'] ?? 0).toDouble();
    final discount = (item['mien_giam'] ?? 0).toDouble();
    final paid = (item['da_thu'] ?? 0).toDouble();
    final debt = (item['con_no'] ?? 0).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: debt > 0 ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['ten_hoc_ky'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: debt > 0 ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  debt > 0 ? 'Còn nợ' : 'Đã đóng đủ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: debt > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTuitionRow('Học phí', controller.formatCurrency(tuition)),
          _buildTuitionRow('Miễn giảm', controller.formatCurrency(discount), isDiscount: true),
          _buildTuitionRow('Đã đóng', controller.formatCurrency(paid), isPaid: true),
          Divider(height: 16.h),
          _buildTuitionRow('Còn nợ', controller.formatCurrency(debt), isDebt: true),
        ],
      ),
    );
  }

  Widget _buildTuitionRow(String label, String value, {bool isDiscount = false, bool isPaid = false, bool isDebt = false}) {
    Color valueColor = Colors.black87;
    if (isDiscount) valueColor = Colors.orange;
    if (isPaid) valueColor = Colors.green;
    if (isDebt) valueColor = Colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isDebt ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
