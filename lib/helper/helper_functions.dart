//to convert string to double

import 'package:intl/intl.dart';

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//to add dollars/ruppee with the amount
String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: "en_US", symbol: "\₹");
  return format.format(amount);
}
