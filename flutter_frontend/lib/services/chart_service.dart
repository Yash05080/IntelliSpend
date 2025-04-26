import 'package:finance_manager_app/models/expensemodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChartService {
  final supabase = Supabase.instance.client;

  Future<List<ExpenseDayData>> fetchLast7DaysExpenses(String userId) async {
    try {
      // Get the current date
      final now = DateTime.now();

      // Calculate start date (7 days ago, including today)
      final startDate = DateTime(now.year, now.month, now.day - 6);

      // Format dates for the Supabase query
      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(now);

      print("Fetching expenses from $startDateStr to $endDateStr");

      // Try with updated method (with date parameters)
      try {
        final result = await supabase.rpc('get_last_7_days_expenses', params: {
          'user_id': userId,
          'start_date': startDateStr,
          'end_date': endDateStr,
        });

        print("Got result with date params: $result");

        // Parse the result
        return _parseResult(result);
      } catch (e) {
        print("Error with date params: $e");

        // Fall back to original method (without date parameters)
        print("Trying original method");
        final result = await supabase
            .rpc('get_last_7_days_expenses', params: {'user_id': userId});

        print("Got result with original method: $result");

        // Parse the result
        return _parseResult(result);
      }
    } catch (e) {
      print("Critical error in ChartService: $e");
      // Return empty list in case of error
      return [];
    }
  }

  List<ExpenseDayData> _parseResult(dynamic result) {
    if (result == null) return [];

    try {
      return (result as List<dynamic>).map((e) {
        return ExpenseDayData(
          date: DateTime.parse(e['date']),
          total: (e['total'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      print("Error parsing result: $e");
      return [];
    }
  }
}
