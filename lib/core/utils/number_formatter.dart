/// Utility class để format số lớn (coins, diamonds, XP...)
class NumberFormatter {
  /// Format số lớn thành dạng ngắn gọn
  /// 1000 -> 1K, 1500000 -> 1.5M, 2250000000 -> 2.25B
  static String compact(int number) {
    if (number >= 1000000000) {
      final billions = number / 1000000000;
      return '${billions.toStringAsFixed(billions >= 10 ? 1 : 2)}B';
    } else if (number >= 1000000) {
      final millions = number / 1000000;
      return '${millions.toStringAsFixed(millions >= 10 ? 1 : 2)}M';
    } else if (number >= 1000) {
      final thousands = number / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 1 : 2)}K';
    }
    return number.toString();
  }

  /// Format số với dấu phân cách hàng nghìn
  /// 1234567 -> 1,234,567
  static String withCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format số với đơn vị tiếng Việt
  /// 1000000 -> 1 triệu, 1000000000 -> 1 tỷ
  static String vietnamese(int number) {
    if (number >= 1000000000) {
      final billions = number / 1000000000;
      return '${billions.toStringAsFixed(billions >= 10 ? 1 : 2)} tỷ';
    } else if (number >= 1000000) {
      final millions = number / 1000000;
      return '${millions.toStringAsFixed(millions >= 10 ? 1 : 2)} triệu';
    } else if (number >= 1000) {
      final thousands = number / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 1 : 2)} nghìn';
    }
    return number.toString();
  }

  /// Format tiền tệ VND với dấu chấm phân cách
  /// 1234567 -> 1.234.567
  static String currency(num amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Format phần trăm
  /// 85.5 -> 85.5%
  static String percent(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Parse dynamic value thành double an toàn
  /// Hỗ trợ null, num, String
  static double parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse dynamic value thành int an toàn
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
