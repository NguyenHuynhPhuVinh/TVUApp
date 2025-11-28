import '../utils/number_formatter.dart';

/// Extensions cho số - format tiền tệ và số liệu
extension CurrencyExtension on num {
  /// Format tiền VND với đơn vị đ
  /// 1234567 -> "1.234.567đ"
  String get toVND => '${NumberFormatter.currency(this)}đ';

  /// Format số với dấu phân cách hàng nghìn
  /// 1234567 -> "1,234,567"
  String get toCommas => NumberFormatter.withCommas(toInt());

  /// Format số lớn thành dạng ngắn gọn
  /// 1500000 -> "1.5M"
  String get toCompact => NumberFormatter.compact(toInt());

  /// Format số với đơn vị tiếng Việt
  /// 1500000 -> "1.5 triệu"
  String get toVietnamese => NumberFormatter.vietnamese(toInt());
}

/// Extensions cho int - format game stats
extension GameStatsExtension on int {
  /// Format XP/Coins/Diamonds
  String get formatted => NumberFormatter.compact(this);

  /// Format với dấu + phía trước (cho rewards)
  String get withPlus => '+${NumberFormatter.compact(this)}';
}
