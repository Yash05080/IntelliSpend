import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;

  const DatePickerWidget({super.key, this.onDateSelected});

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor:
                const Color(0xFF34394B), // 🎯 Custom background color
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.secondary, // Header color
              onPrimary: Colors.white, // Header text color
              surface: const Color(0xFF34394B), // Calendar background
              onSurface: Colors.white, // Text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(fontWeight: FontWeight.w800),
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .tertiary, // Button text color (e.g., CANCEL, OK)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected?.call(picked); // 🔥 Callback to parent
    }
  }

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
              getFormattedDate(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
