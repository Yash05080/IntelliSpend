import 'package:finance_manager_app/models/expense.dart';
import 'package:finance_manager_app/services/expens_service.dart';
import 'package:flutter/material.dart';


class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<Transaction> transactions = [];
  bool loading = false;
  String? errorMessage;

  Future<void> fetchTransactions(String token) async {
    // Defer call until after build if needed.
    await Future.delayed(Duration(milliseconds: 1));

    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      transactions = await _transactionService.fetchTransactions(token);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(String token, Transaction txn) async {
    loading = true;
    notifyListeners();
    try {
      Transaction newTxn = await _transactionService.addTransaction(token, txn);
      transactions.add(newTxn);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
