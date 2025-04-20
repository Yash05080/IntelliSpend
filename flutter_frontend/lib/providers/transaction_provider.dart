import 'package:finance_manager_app/services/transaction_service.dart';
import 'package:flutter/foundation.dart';


class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> get transactions => _transactions;

  bool _loading = false;
  bool get loading => _loading;

  /// Fetch all transactions
  Future<void> loadTransactions() async {
    _loading = true;
    notifyListeners();
    _transactions = await _service.fetchTransactions();
    _loading = false;
    notifyListeners();
  }

  /// Create a new expense
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    String? description,
    DateTime? date,
  }) async {
    await _service.createTransaction(
      title: title,
      amount: amount,
      category: category,
      description: description,
      date: date,
    );
    await loadTransactions();
  }

  /// Update an existing one
  Future<void> editTransaction({
    required String id,
    String? title,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    await _service.updateTransaction(
      id: id,
      title: title,
      amount: amount,
      category: category,
      description: description,
      date: date,
    );
    await loadTransactions();
  }

  /// Delete by id
  Future<void> removeTransaction(String id) async {
    await _service.deleteTransaction(id);
    await loadTransactions();
  }
}
