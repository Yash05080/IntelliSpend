import 'package:finance_manager_app/pages/add%20expense/veiws/dropdownmenu.dart';
import 'package:finance_manager_app/widgets/datepicker.dart';
import 'package:finance_manager_app/widgets/timepicker.dart';

import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';

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
                "assets/images/bg1.png",
                fit: BoxFit.fill,
              ),
            ),
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
                      color: Colors.white, // Text color
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
                          color: Colors.white
                              .withOpacity(0.8), // Light shadow color
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
                              HexColor("0D7377"), // Dark Teal
                              HexColor("32E0C4"), // Light Teal
                              HexColor("393E46"), // Dark Gray
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
                      color: Colors.grey[
                          300], // A neutral background color to enhance Neomorphism
                      borderRadius: BorderRadius.circular(12), // Rounded edges
                      boxShadow: [
                        // Dark shadow for the bottom-right
                        BoxShadow(
                          color: Colors.grey[300]!,
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
                      color: Colors.grey[
                          300], // Neutral background color for Neomorphism
                      borderRadius: BorderRadius.circular(12), // Rounded edges
                      boxShadow: [
                        // Dark shadow for bottom-right
                        BoxShadow(
                          color: Colors.grey[300]!,
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
                          color: Colors.grey[300], // Base color for Neomorphism
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
                              color: Colors.white,
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
                                    HexColor("0D7377"), // Dark Teal
                                    HexColor("32E0C4"), // Light Teal
                                    HexColor("393E46"), // Dark Gray
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
