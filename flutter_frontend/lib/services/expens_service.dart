import 'package:dio/dio.dart';
import 'package:finance_manager_app/models/expense.dart';


class TransactionService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8080/api', // Adjust as needed.
  ));

  // Fetch transactions for the logged-in user.
  Future<List<Transaction>> fetchTransactions(String token) async {
    try {
      Response response = await _dio.get(
        '/transactions',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Add a new transaction.
  Future<Transaction> addTransaction(String token, Transaction txn) async {
    try {
      Response response = await _dio.post(
        '/transactions',
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: txn.toJson(),
      );
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }
}
