import 'dart:math';

import 'package:finance_manager_app/pages/Home/veiws/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(50),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          //showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Theme.of(context).colorScheme.secondary,
          selectedItemColor:Theme.of(context).colorScheme.primary,
          selectedIconTheme: IconThemeData(size: 25),
          items: const [
            BottomNavigationBarItem(
              icon: Hero(
                tag: "home",
                child: Icon(
                  Icons.home_outlined,
                  size: 35,
                ),
              ),
              activeIcon: Hero(
                tag: "home",
                child: Icon(
                  Icons.home,
                  size: 30,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.bar_chart,
                size: 35,
              ),
              label: "Statistics",
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 10,
        focusElevation: 0,
        shape: CircleBorder(),
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
              transform: GradientRotation(pi / 4),
            ),
          ),
          child: Icon(
            Icons.add,
            size: 32,
          ),
        ),
      ),
      body: MainScreen(),
    );
  }
}
