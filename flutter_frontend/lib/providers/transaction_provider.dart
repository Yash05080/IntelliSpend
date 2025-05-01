import 'package:finance_manager_app/services/transaction_service.dart';
import 'package:flutter/foundation.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> get transactions => _transactions;

  double _totalBalance = 0.0;
  double get totalBalance => _totalBalance;

  bool _loading = false;
  bool get loading => _loading;

  /// Fetch all transactions and update balance
  Future<void> loadTransactions() async {
    _loading = true;
    notifyListeners();
    
    try {
      _transactions = await _service.fetchTransactions();
      _calculateTotalBalance();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Calculate the total balance from all transactions
  void _calculateTotalBalance() {
    _totalBalance = 0.0;
    for (var transaction in _transactions) {
      _totalBalance += transaction['amount'];
    }
  }

  /// Create a new transaction
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    String? description,
    DateTime? date,
  }) async {
    _loading = true;
    notifyListeners();
    
    try {
      await _service.createTransaction(
        title: title,
        amount: amount,
        category: category,
        description: description ?? '',
        date: date ?? DateTime.now(),
      );
      await loadTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      _loading = false;
      notifyListeners();
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    required double oldAmount,
  }) async {
    _loading = true;
    notifyListeners();
    
    try {
      await _service.updateTransaction(
        id: id,
        title: title,
        amount: amount,
        category: category,
        description: description,
        date: date,
      );
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a transaction by ID
  Future<void> deleteTransaction(String id, double amount) async {
    _loading = true;
    notifyListeners();
    
    try {
      await _service.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
}