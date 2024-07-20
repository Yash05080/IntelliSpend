import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:keep_the_count/Online/Onlinehome.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

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

                //save button
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openNewExpenseBox,
        child: Icon(Icons.add),
      ),
    );
  }
}
