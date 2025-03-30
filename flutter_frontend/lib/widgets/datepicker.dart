import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime _selectedDate = DateTime.now(); // Initial date set to today's date

  // Function to pick the date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),  // Earliest selectable date
      lastDate: DateTime(2101),   // Latest selectable date
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Formatting the selected date for display
  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              blurRadius: 10,
              offset: const Offset(3, 3),
            ),
            const BoxShadow(
              color: Color.fromARGB(255, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(-3, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${getFormattedDate()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10,),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
