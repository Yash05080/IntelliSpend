import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final _client = Supabase.instance.client;
  
  Future<String> getCurrentUserId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    return userId;
  }
  /// Saves a single transaction to Supabase (transactions + balance).
  Future<void> saveTransaction(Map<String, dynamic> txn) async {
    final userId = await getCurrentUserId();
    final DateTime date = DateTime.parse(txn['date'] as String);

    await _client.rpc('start_transaction');

    try {
      // Insert into transactions
      await _client.from('transactions').insert({
        'user_id': userId,
        'title': txn['title'],
        'description': txn['description'],
        'amount': txn['amount'],
        'category': txn['category'],
        'date': date.toIso8601String(),
      });

      // Insert into balance
      await _client.from('balance').insert({
        'user_id': userId,
        'amount': txn['amount'],
        'type': 'debit',
        'created_at': date.toIso8601String(),
      });

      await _client.rpc('commit_transaction');
    } catch (e) {
      await _client.rpc('rollback_transaction');
      rethrow;
    }
  }

    /// Parses Gemini’s JSON, saves each txn, and returns the list of saved items.
  Future<List<Map<String, dynamic>>> saveAllFromGemini(String jsonString) async {
    final List<dynamic> parsed = jsonDecode(jsonString);
    final List<Map<String, dynamic>> saved = [];

    for (final item in parsed) {
      final Map<String, dynamic> txn = Map<String, dynamic>.from(item);
      await saveTransaction(txn);
      saved.add(txn);
    }
    return saved;
  }



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
    
    // Use a transaction to ensure both operations succeed or fail together
    await _client.rpc('start_transaction');
    
    try {
      // Insert into transactions table
      await _client.from('transactions').insert({
        'user_id': userId,
        'title': title,
        'amount': amount,
        'category': category,
        'description': description ?? '',
        'date': (date ?? DateTime.now()).toIso8601String(),
      });

      // Insert into balance table to track expense
      await _client.from('balance').insert({
        'user_id': userId,
        'amount': amount,
        'type': 'debit',
        'created_at': (date ?? DateTime.now()).toIso8601String(),
      });
      
      await _client.rpc('commit_transaction');
    } catch (e) {
      await _client.rpc('rollback_transaction');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)  // Filter by current user
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
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    
    // Prepare updates for the transaction
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (amount != null) updates['amount'] = amount;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (date != null) updates['date'] = date.toIso8601String();

    // Apply the updates
    await _client
        .from('transactions')
        .update(updates)
        .eq('id', id)
        .eq('user_id', userId);  // Ensure we only update user's own records
  }

  Future<void> deleteTransaction(String id) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Delete the transaction
    await _client
        .from('transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);  // Ensure we only delete user's own records
  }
}