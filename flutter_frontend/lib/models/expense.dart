class Transaction {
  final String id;
  final String name;
  final String totalAmount;
  final DateTime date;
  final String description;
  final String category;
  final String type;

  Transaction({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.date,
    required this.description,
    required this.category,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      name: json['name'] as String,
      totalAmount: json['totalamount'].toString(),
      date: DateTime.parse(json['date']),
      description: json['description'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalamount': totalAmount,
      'date': date.toIso8601String(),
      'description': description,
      'category': category,
      'type': type,
    };
  }
}
