import 'package:intl/intl.dart';

class NumberFormatCurrency {
  static String formatCurrencyIdr(double amount) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount);
  }
}
