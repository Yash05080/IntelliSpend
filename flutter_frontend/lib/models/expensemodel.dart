class ExpenseDayData {
  final DateTime date;
  final double total;

  ExpenseDayData({
    required this.date,
    required this.total,
  });

  factory ExpenseDayData.fromMap(Map<String, dynamic> map) {
    return ExpenseDayData(
      date: DateTime.parse(map['date']),
      total: (map['total'] as num).toDouble(),
    );
  }
}
