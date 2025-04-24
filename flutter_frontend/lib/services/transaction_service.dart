import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final _client = Supabase.instance.client;
  Future<Map<String, double>> getExpenseByCategory(String userId) async {

  final response = await _client
      .from('transactions')
      .select('category, amount')
      .eq('user_id', userId);
      

  if (response.isEmpty) return {};

  Map<String, double> categoryTotals = {};

  for (var item in response) {
    final category = item['category'] as String;
    final amount = (item['amount'] as num).toDouble();

    if (categoryTotals.containsKey(category)) {
      categoryTotals[category] = categoryTotals[category]! + amount;
    } else {
      categoryTotals[category] = amount;
    }
  }

  return categoryTotals;
}

  Future<void> createTransaction({
    required String title,
    required double amount,
    required String category,
    String? description,
    DateTime? date,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _client.from('transactions').insert({
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'description': description ?? '',
      'date': (date ?? DateTime.now()).toIso8601String(),
    });

    await _client.from('balance').insert({
    'user_id': userId,
    'amount': amount,
    'type': 'debit',
    'created_at': (date ?? DateTime.now()).toIso8601String(),
  });
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('transactions')
        .select()
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateTransaction({
    required String id,
    String? title,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (amount != null) updates['amount'] = amount;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (date != null) updates['date'] = date.toIso8601String();

    await _client.from('transactions').update(updates).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }
}
