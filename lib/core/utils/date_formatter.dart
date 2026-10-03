/// Utilitas formatting dan kalkulasi tanggal dengan acuan zona waktu UTC+7 (WIB).
class DateFormatter {
  /// Acuan waktu UTC+7 (Waktu Indonesia Barat - WIB)
  static const Duration utc7Offset = Duration(hours: 7);

  static const List<String> _monthNamesIndo = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthNamesShortIndo = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Mengonversi DateTime ke zona waktu UTC+7 (WIB)
  static DateTime toUtc7(DateTime date) {
    if (date.isUtc) {
      return date.add(utc7Offset);
    }
    return date.toUtc().add(utc7Offset);
  }

  /// Parsing tanggal dari string/dynamic yang aman dan menghasilkan DateTime UTC+7
  static DateTime parseUtc7(dynamic dateRaw) {
    if (dateRaw == null) return toUtc7(DateTime.now());
    if (dateRaw is DateTime) return toUtc7(dateRaw);

    final str = dateRaw.toString().trim();
    if (str.isEmpty) return toUtc7(DateTime.now());

    try {
      final parsed = DateTime.parse(str);
      if (str.endsWith('Z') || str.contains('+00:00')) {
        return parsed.toUtc().add(utc7Offset);
      }
      if (parsed.isUtc) {
        return parsed.add(utc7Offset);
      }
      return parsed;
    } catch (_) {
      return toUtc7(DateTime.now());
    }
  }

  /// Format ringkas untuk list tile: '03 Okt, 17:00' (UTC+7)
  static String formatShort(DateTime date) {
    final dt = toUtc7(date);
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthNamesShortIndo[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month, $hour:$minute';
  }

  /// Format lengkap dengan penanda WIB: '03 Oktober 2026, 17:00 WIB'
  static String formatFull(DateTime date) {
    final dt = toUtc7(date);
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthNamesIndo[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute WIB';
  }

  /// Format tanggal saja: '03 Oktober 2026'
  static String formatDateOnly(DateTime date) {
    final dt = toUtc7(date);
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthNamesIndo[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
  }

  /// Format waktu saja: '17:00 WIB'
  static String formatTimeOnly(DateTime date) {
    final dt = toUtc7(date);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}
