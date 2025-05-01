import 'dart:math';

import 'package:finance_manager_app/pages/Home/veiws/main_screen.dart';
import 'package:finance_manager_app/pages/Stats/statspage.dart';
import 'package:finance_manager_app/pages/add%20expense/docpicker.dart';
import 'package:finance_manager_app/pages/add%20expense/veiws/add_expense.dart';
import 'package:finance_manager_app/pages/add%20expense/veiws/camera.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int index = 0;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _blurAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(50),
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              elevation: 5,
              backgroundColor: HexColor("34394b"),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              unselectedItemColor: Theme.of(context).colorScheme.secondary,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              selectedIconTheme: const IconThemeData(size: 30),
              unselectedIconTheme: const IconThemeData(size: 25),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          backgroundColor: HexColor("191d2d"),
          body: index == 0 ? const MainScreen() : const StatsPage(),
        ),

        // Blur overlay when expanded
        AnimatedBuilder(
          animation: _blurAnimation,
          builder: (context, child) {
            return IgnorePointer(
              ignoring: !_isExpanded,
              child: GestureDetector(
                onTap: _isExpanded ? _toggleExpand : null,
                child: Container(
                  color: _isExpanded
                      ? Colors.black.withOpacity(0.3)
                      : Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            );
          },
        ),

        // Main FAB and expanded buttons
        Positioned(
          bottom: 16,
          left: MediaQuery.of(context).size.width / 2 - 28,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Camera button
              ScaleTransition(
                scale: _expandAnimation,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: FloatingActionButton(
                          heroTag: "camera",
                          onPressed: () {
                            // Camera functionality here
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OCRCapturePage()));
                            _toggleExpand();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 28,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              // Note/List button
              ScaleTransition(
                scale: _expandAnimation,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: FloatingActionButton(
                          heroTag: "note",
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddExpense()));
                            _toggleExpand();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: const Icon(
                            Icons.note_alt,
                            size: 28,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              // Document button
              ScaleTransition(
                scale: _expandAnimation,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: FloatingActionButton(
                          heroTag: "document",
                          onPressed: () {
                            // Document functionality here
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  DocumentPickerPage()));

                            _toggleExpand();
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.description,
                            size: 28,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              // Main FAB
              FloatingActionButton(
                onPressed: _toggleExpand,
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
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * pi / 4,
                        child: Icon(
                          _isExpanded ? Icons.close : Icons.add,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
