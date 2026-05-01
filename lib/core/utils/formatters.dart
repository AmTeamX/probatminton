import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(double amount) {
    return '\u0E3F${NumberFormat('#,##0').format(amount)}';
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String time(String time24) {
    // Handle ISO datetime strings (e.g. "2026-05-01T12:00:00Z")
    String raw = time24;
    if (raw.contains('T')) {
      // Extract the time portion after 'T'
      raw = raw.split('T').last;
    }
    // Remove trailing 'Z' or timezone offset
    raw = raw.replaceAll(RegExp(r'[Zz]$'), '');
    // Handle timezone offset like +07:00
    final tzMatch = RegExp(r'[+-]\d{2}:\d{2}$').firstMatch(raw);
    if (tzMatch != null) {
      raw = raw.substring(0, tzMatch.start);
    }

    final parts = raw.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  static String distance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
