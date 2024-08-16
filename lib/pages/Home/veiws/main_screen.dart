import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: HexColor("105d5e")),
                      child: Center(
                          child: Text(
                        "Y",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 25),
                      )),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "welcome",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        Text(
                          "Yash Agarwal",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                        )
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                    transform: GradientRotation(pi / 8),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        offset: Offset(0, 8),
        blurRadius: 10,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        offset: Offset(0, 12),
        blurRadius: 14,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        offset: Offset(0, 16),
        blurRadius: 18,
        spreadRadius: 0,
      ),
    ],
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Total Balance",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 10,),
                  Text(
                    "₹ 5000.00",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_downward,
                                  size: 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              children: [
                                Text("Income"),
                                Text("₹8000"),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_upward_outlined,
                                  size: 14,
                                  
                                ),
                              ),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              children: [
                                Text("Expenses"),
                                Text("₹3000"),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
