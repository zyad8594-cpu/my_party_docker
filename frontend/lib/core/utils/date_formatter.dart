import 'package:intl/intl.dart';

class DateFormatter {
  static String format(String? dateStr, {String fallback = 'غير محدد'}) {
    if (dateStr == null || dateStr.trim().isEmpty) return fallback;
    try {
      return DateFormat('yyyy/MM/dd', 'ar').format(DateTime.parse(dateStr));
    } catch (e) {
      return fallback;
    }
  }

  static String formatDateTime(String? dateStr, {String fallback = 'غير محدد'}) {
    if (dateStr == null || dateStr.trim().isEmpty) return fallback;
    try {
      return DateFormat('yyyy/MM/dd hh:mm a', 'ar').format(DateTime.parse(dateStr));
    } catch (e) {
      return fallback;
    }
  }

  static String formatTime(String? dateStr, {String fallback = 'غير محدد'}) {
    if (dateStr == null || dateStr.trim().isEmpty) return fallback;
    try {
      return DateFormat('hh:mm a', 'ar').format(DateTime.parse(dateStr));
    } catch (e) {
      return fallback;
    }
  }
}
