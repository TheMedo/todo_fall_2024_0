import 'package:intl/intl.dart';

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(Duration(days: 1));
  final yesterday = today.subtract(Duration(days: 1));
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final weekEnd = weekStart.add(Duration(days: 6));

  final timeFormat = DateFormat('h:mm a');
  final dateFormat = DateFormat('MMM d, yyyy');
  final dayMonthTimeFormat = DateFormat('EEE h:mm a');
  final monthDayTimeFormat = DateFormat('MMM d, h:mm a');

  if (dateTime.isAfter(today) && dateTime.isBefore(tomorrow)) {
    return 'Today ${timeFormat.format(dateTime)}';
  } else if (dateTime.isAfter(yesterday) && dateTime.isBefore(today)) {
    return 'Yesterday ${timeFormat.format(dateTime)}';
  } else if (dateTime.isAfter(today) && dateTime.isBefore(tomorrow.add(Duration(days: 1)))) {
    return 'Tomorrow ${timeFormat.format(dateTime)}';
  } else if (dateTime.isAfter(tomorrow) && dateTime.isBefore(weekEnd)) {
    return dayMonthTimeFormat.format(dateTime);
  } else if (dateTime.isBefore(weekStart)) {
    return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
  } else {
    return monthDayTimeFormat.format(dateTime);
  }
}
