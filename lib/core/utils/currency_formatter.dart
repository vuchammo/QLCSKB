import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final NumberFormat _vndFormat = NumberFormat('#,###', 'vi_VN');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.0', 'vi_VN');

  static String format(double amount, {String currency = AppConstants.currencyVnd}) {
    if (currency == AppConstants.currencyVnd) {
      return '${_vndFormat.format(amount.round())} đ';
    } else {
      // Thỏi vàng
      if (amount % 1 == 0) {
        return '${_vndFormat.format(amount.toInt())} TV';
      }
      return '${_decimalFormat.format(amount)} TV';
    }
  }

  static String formatNumber(num number) {
    return _vndFormat.format(number);
  }

  static String formatDecimal(double number) {
    return _decimalFormat.format(number);
  }
}
