import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatFull(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }
}
