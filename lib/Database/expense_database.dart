import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:keep_the_count/model/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*

  S E T U P

   */

  //initialise db

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*
  
  G E T T E R S
  
   */

  List<Expense> get allExpense => _allExpenses;

  /*
  
  O P E R A T I O N S
  
   */

  //create - add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    //add in db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //re-read from db
    readExpenses();
  }

  //read - expenses from db
  Future<void> readExpenses() async {
    //fetch all existing data from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    //give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    //update UI
    notifyListeners();
  }

  //update - edit an expense in db
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    //make sure expenseshas same id as existing one
    updatedExpense.id = id;

    //update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    //re-read from db
    await readExpenses();
  }

  //delete - an expense
  Future<void> deleteExpense(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re-read from db
    await readExpenses();
  }

  /*

  H E L P E R

  */
}
