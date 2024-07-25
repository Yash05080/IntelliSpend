import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String name;
  final String amount;
  final String Day;
  final String month;
  final String year;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  const MyListTile({
    super.key,
    required this.name,
    required this.amount,
    required this.Day,
    required this.month,
    required this.year,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          //on edit pressed
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.edit,
          ),

          //on delete pressed
          SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        subtitle: Text("$Day/ $month/ $year"),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(amount),
      ),
    );
  }
}
