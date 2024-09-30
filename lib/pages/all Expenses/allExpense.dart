// ignore: file_names
import 'package:flutter/material.dart';

class AllExpense extends StatelessWidget {
  const AllExpense({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SafeArea(child: Column(children: [Text("all expenses")],)),
    );
  }
}