class Transaction {
  final String id;
  final String description;
  final String category;
  final double amount;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
