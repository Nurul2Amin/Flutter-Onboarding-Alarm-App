import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime); // e.g., 8:30 PM
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime); // e.g., Sep 5, 2025
  }
}
