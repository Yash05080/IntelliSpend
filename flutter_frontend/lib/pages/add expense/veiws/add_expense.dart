import 'package:finance_manager_app/pages/add%20expense/veiws/dropdownmenu.dart';
import 'package:finance_manager_app/providers/transaction_provider.dart';
import 'package:finance_manager_app/widgets/datepicker.dart';
import 'package:finance_manager_app/widgets/timepicker.dart';

import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  // ignore: non_constant_identifier_names

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime? _selectedDateTime;

  void _showSnackBar(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.red, // <-- red text always
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isError ? Colors.white : Colors.green[100],
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}


  void saveExpense() async {
  try {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      _showSnackBar("Enter a valid amount", isError: true);
      return;
    }

    if (_selectedDateTime == null) {
      _showSnackBar("Please select date and time", isError: true);
      return;
    }

    await TransactionProvider()
        .addTransaction(
          title: "Expense",
          amount: amount,
          category: _selectedCategory,
          description: _noteController.text.trim(),
          date: _selectedDateTime!, // It's safe because we checked for null
        )
        .then((_) {
          _showSnackBar("Transaction added successfully");
          _amountController.clear();
          _noteController.clear();
          setState(() {
            _selectedCategory = 'Food';
            _selectedDateTime = null;
          });
        })
        .catchError((e) =>
            _showSnackBar("Failed to add: ${e.toString()}", isError: true));
  } catch (e) {
    _showSnackBar("Error: ${e.toString()}", isError: true);
  }
}



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
                      controller: _amountController,
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
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.background,
                          offset: const Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        const BoxShadow(
                          color: Color.fromARGB(255, 0, 0, 0),
                          offset: Offset(-4, -4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Center(
                      child: CategoryDropdown(
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
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
                      controller: _noteController,
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
                    children: [
                      DatePickerWidget(
                        onDateSelected: (DateTime date) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              _selectedDateTime?.hour ?? 0,
                              _selectedDateTime?.minute ?? 0,
                            );
                          });
                        },
                      ),
                      TimePickerWidget(
                        onTimeSelected: (TimeOfDay time) {
                          final now = DateTime.now();
                          setState(() {
                            _selectedDateTime = DateTime(
                              _selectedDateTime?.year ?? now.year,
                              _selectedDateTime?.month ?? now.month,
                              _selectedDateTime?.day ?? now.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  //Save button

                  Center(
                    child: GestureDetector(
                      onTap: saveExpense,
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
