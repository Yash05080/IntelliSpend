import 'package:finance_manager_app/models/expensemodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChartService {
  final supabase = Supabase.instance.client;

  Future<List<ExpenseDayData>> fetchLast7DaysExpenses(String userId) async {
  final result = await Supabase.instance.client
      .rpc('get_last_7_days_expenses', params: {'user_id': userId});

  // result is List<dynamic>, parse it
  return (result as List<dynamic>).map((e) {
    return ExpenseDayData(
      date: DateTime.parse(e['date']),
      total: (e['total'] as num).toDouble(),
    );
  }).toList();
}

}
