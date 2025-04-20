import 'package:supabase_flutter/supabase_flutter.dart';

class BalanceService {
  final _client = Supabase.instance.client;

  Future<void> logBalance({
    required String type, // 'credit', 'debit', 'update'
    required double amount,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await _client.from('balance_logs').insert({
      'user_id': user.id,
      'type': type,
      'amount': amount,
    });
  }

  Future<double> fetchTotalBalance() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final response = await _client
        .rpc('get_total_balance', params: {'user_id': user.id})
        .single();

    return (response as num?)?.toDouble() ?? 0.0;
  }
}
