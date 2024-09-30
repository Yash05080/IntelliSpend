

import 'dart:math';

import 'package:finance_manager_app/pages/Home/veiws/main_screen.dart';
import 'package:finance_manager_app/pages/Stats/statspage.dart';
import 'package:finance_manager_app/pages/add%20expense/veiws/add_expense.dart';
import 'package:flutter/material.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(50),
        ),
        child: BottomNavigationBar(
          currentIndex: index, // This determines the selected item
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          elevation: 5,
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          unselectedItemColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          selectedIconTheme:
              const IconThemeData(size: 30), // Size of the selected icon
          unselectedIconTheme:
              const IconThemeData(size: 25), // Size of the unselected icon
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 35,
              ),
              activeIcon: Icon(
                Icons.home,
                size: 30,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.bar_chart,
                size: 35,
              ),
              activeIcon: Icon(
                Icons.bar_chart,
                size: 30,
              ),
              label: "Statistics",
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AddExpense()));
        },
        elevation: 10,
        focusElevation: 0,
        shape: const CircleBorder(),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
              ],
              transform: const GradientRotation(pi / 4),
            ),
          ),
          child: const Icon(
            Icons.add,
            size: 32,
          ),
        ),
      ),
      body: index == 0 ? const MainScreen() : const StatsPage(),
    );
  }
}
