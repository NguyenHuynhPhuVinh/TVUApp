/// Utility class để format và parse ngày tháng
class DateFormatter {
  /// Parse date string dạng dd/MM/yyyy thành DateTime
  static DateTime? parseVietnamese(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;
    try {
      return DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );
    } catch (e) {
      return null;
    }
  }

  /// Format DateTime thành dd/MM/yyyy
  static String toVietnamese(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format DateTime thành dd/MM/yyyy HH:mm
  static String toVietnameseWithTime(DateTime date) {
    return '${toVietnamese(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Parse ISO date string và format thành dd/MM/yyyy HH:mm
  static String formatIsoToVietnamese(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return toVietnameseWithTime(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Kiểm tra ngày hiện tại có nằm trong khoảng không
  static bool isDateInRange(DateTime date, String? startStr, String? endStr) {
    final start = parseVietnamese(startStr);
    final end = parseVietnamese(endStr);
    if (start == null || end == null) return false;
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }
}
