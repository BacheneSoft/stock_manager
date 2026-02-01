import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double value) {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(value);
  }
}
