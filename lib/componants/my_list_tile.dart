import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String name;
  final String amount;
  final String Day;
  final String month;
  final String year;
  const MyListTile(
      {super.key,
      required this.name,
      required this.amount,
      required this.Day,
      required this.month,
      required this.year});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Text("$Day/ $month/ $year"),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Text(amount),
    );
  }
}
