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
              Expanded(child: _buildSummaryItem('Tổng phải thu', controller.formatCurrency(controller.totalTuition.value), Iconsax.receipt, Colors.white)),
              SizedBox(width: 16.w),
              Expanded(child: _buildSummaryItem('Đã đóng', controller.formatCurrency(controller.totalPaid.value), Iconsax.tick_circle, Colors.greenAccent)),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: controller.totalDebt.value > 0 ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.totalDebt.value > 0 ? Iconsax.warning_2 : Iconsax.tick_circle,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  controller.totalDebt.value > 0 
                      ? 'Còn nợ: ${controller.formatCurrency(controller.totalDebt.value)}'
                      : 'Đã đóng đủ học phí',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
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
            Icon(icon, size: 16.sp, color: iconColor),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
          ],
        ),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
              Text('Chưa có thông tin học phí', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
            ],
          ),
        );
      }

      // Reverse để học kỳ mới nhất lên đầu
      final reversedList = controller.tuitionList.reversed.toList();
      
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: reversedList.length,
        itemBuilder: (context, index) => _buildTuitionCard(reversedList[index]),
      );
    });
  }

  Widget _buildTuitionCard(Map<String, dynamic> item) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final hocPhi = parseDouble(item['hoc_phi']);
    final mienGiam = parseDouble(item['mien_giam']);
    final duocHoTro = parseDouble(item['duoc_ho_tro']);
    final phaiThu = parseDouble(item['phai_thu']);
    final daThu = parseDouble(item['da_thu']);
    final conNo = parseDouble(item['con_no']);
    final donGia = parseDouble(item['don_gia']);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: conNo > 0 ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['ten_hoc_ky'] ?? 'N/A',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: conNo > 0 ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  conNo > 0 ? 'Còn nợ' : 'Đã đóng đủ',
                  style: TextStyle(fontSize: 12.sp, color: conNo > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTuitionRow('Học phí', controller.formatCurrency(hocPhi)),
          if (mienGiam > 0) _buildTuitionRow('Miễn giảm', '-${controller.formatCurrency(mienGiam)}', color: Colors.orange),
          if (duocHoTro > 0) _buildTuitionRow('Được hỗ trợ', '-${controller.formatCurrency(duocHoTro)}', color: Colors.blue),
          Divider(height: 16.h),
          _buildTuitionRow('Phải thu', controller.formatCurrency(phaiThu), isBold: true),
          _buildTuitionRow('Đã đóng', controller.formatCurrency(daThu), color: Colors.green),
          if (conNo > 0) _buildTuitionRow('Còn nợ', controller.formatCurrency(conNo), color: Colors.red, isBold: true),
          if (donGia > 0) ...[
            SizedBox(height: 8.h),
            Text('Đơn giá: ${controller.formatCurrency(donGia)}/TC', style: TextStyle(fontSize: 11.sp, color: Colors.grey[500], fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildTuitionRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
