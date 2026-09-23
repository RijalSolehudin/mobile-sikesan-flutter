import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShort(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMM, HH:mm', 'id_ID');
    return formatter.format(date);
  }

  static String formatFull(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}
