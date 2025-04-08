import 'package:finance_manager_app/models/expense.dart';
import 'package:finance_manager_app/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:finance_manager_app/providers/auth_providers.dart'; // Ensure filename matches your project

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedCategory = "Food"; // Default category
  String selectedType = "expense";    // "expense" or "income"
  DateTime selectedDate = DateTime.now();

  void _saveTransaction() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txnProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (authProvider.token == null) return;

    Transaction newTxn = Transaction(
      id: "0", // Actual ID set by backend
      name: _nameController.text,
      totalAmount: _amountController.text,
      date: selectedDate,
      description: _descriptionController.text,
      category: selectedCategory,
      type: selectedType,
    );

    bool success = await txnProvider.addTransaction(authProvider.token!, newTxn);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(txnProvider.errorMessage ?? "Error saving transaction")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simplified UI for adding a transaction.
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Transaction Name"),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: <String>[
                "Food",
                "Shopping",
                "Entertainment",
                "Travel",
                "Medical",
                "Recharge",
                "Rent",
                "Automobile",
                "Others"
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedType,
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              items: <String>["expense", "income"].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text("Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}


/*
class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  // ignore: non_constant_identifier_names
  TextEditingController Amount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child: Image.asset(
                  'assets/backgrounds/bg.jpg',
                  fit: BoxFit.fill,
                )),
            SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.cancel_outlined,
                          size: 30,
                        )),
                  ),
                  Text(
                    "Add Expense",
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'cool',
                      color: Colors.white,
                      //Theme.of(context).colorScheme.primary, // Text color
                      shadows: [
                        Shadow(
                          offset: const Offset(4, 4), // Dark shadow offset
                          blurRadius: 10,
                          color: Colors.black
                              .withOpacity(0.4), // Dark shadow color
                        ),
                        Shadow(
                            offset: const Offset(-1, -2), // Light shadow offset
                            blurRadius: 10,
                            color: HexColor("ffffff") // Light shadow color
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //textfeild
                  Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 125,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: <Color>[
                              HexColor("F2C341"),
                              HexColor("f1a410"),
                              HexColor("f3696e"),
                            ],
                          ).createShader(const Rect.fromLTWH(0, 0, 300, 125)),
                        shadows: [
                          // Dark shadow for the bottom-right
                          Shadow(
                            offset: const Offset(4, 4), // Shadow offset
                            blurRadius: 10, // Blur radius
                            color: Colors.black.withOpacity(0.3), // Dark shadow
                          ),
                          // Light shadow for the top-left
                          Shadow(
                            offset: const Offset(-4, -4), // Light shadow offset
                            blurRadius: 10, // Blur radius for softness
                            color:
                                Colors.white.withOpacity(0.8), // Light shadow
                          ),
                        ],
                      ),
                      decoration: InputDecoration(
                        hintText: "00",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 125,
                          color:
                              Colors.blueGrey[200], // Light gray for hint text
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // name

                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12), // Rounded edges
                      boxShadow: [
                        // Dark shadow for the bottom-right
                        BoxShadow(
                          color: Theme.of(context).colorScheme.background,
                          offset: const Offset(4, 4), // Dark shadow position
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        // Light shadow for the top-left
                        const BoxShadow(
                          color: Color.fromARGB(255, 0, 0, 0),
                          offset: Offset(-4, -4), // Light shadow position
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary), // Primary color border
                    ),
                    child: const Center(
                        child:
                            CategoryDropdown()), // Centering the dropdown inside
                  ),
                  const SizedBox(height: 30),

                  //description

                  Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12), // Rounded edges
                      boxShadow: [
                        // Dark shadow for bottom-right
                        BoxShadow(
                          color: Theme.of(context).colorScheme.background,
                          offset: const Offset(4, 4), // Position of dark shadow
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        // Light shadow for top-left
                        const BoxShadow(
                          color: Color.fromARGB(255, 0, 0, 0),
                          offset: Offset(-4, -4), // Position of light shadow
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Note",
                        hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [const DatePickerWidget(), TimePickerWidget()],
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  //Save button

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Add the functionality for the button press
                      },
                      child: Container(
                        width: 200,
                        height: 80,
                        //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            // Dark shadow for bottom-right
                            BoxShadow(
                              color: Color.fromARGB(255, 38, 38, 38),
                              offset: Offset(4, 4),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                            // Light shadow for top-left
                            BoxShadow(
                              color: Color.fromARGB(255, 111, 117, 144),
                              offset: Offset(-4, -4),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "SAVE",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: <Color>[
                                    HexColor("F2C341"),
                                    HexColor("f1a410"),
                                    HexColor("f3696e"),
                                  ],
                                ).createShader(const Rect.fromLTWH(
                                    0, 0, 250, 35)), // Gradient size
                              shadows: [
                                // Slight shadow to enhance text pop
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 5,
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
*/