import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keep_the_count/Database/expense_database.dart';
import 'package:keep_the_count/helper/stringtoint.dart';
import 'package:keep_the_count/model/expense.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    super.initState();
  }

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "name"),
                  ),
                  // user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: "amount"),
                  ),
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),

                //save button
                _saveButton()
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
        builder: (context, value, child) => Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: openNewExpenseBox,
              child: Icon(Icons.add),
            ),
            body: ListView.builder(
                itemCount: value.allExpense.length,
                itemBuilder: (context, index) {
                  //get individual expense
                  Expense individualExpense = value.allExpense[index];
                  //return Listtile UI
                  return ListTile(
                    title: Text(individualExpense.name),
                    trailing: Text(individualExpense.amount.toString()),
                  );
                })));
  }

  //CANCEL button

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controller
        nameController.clear();
        amountController.clear();
      },
      child: Text("Cancel"),
    );
  }

  // SAVE button
  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        //only save if bopth name and amount is filled
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());

          //save in db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          //clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: Text("Save"),
    );
  }
}
