import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For time formatting

class TimePickerWidget extends StatefulWidget {
  const TimePickerWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay _selectedTime = TimeOfDay.now(); // Initial time set to current time

  // Function to pick the time
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Formatting the selected time for display
  String getFormattedTime() {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    return DateFormat('hh:mm a').format(dt); // 12-hour format with AM/PM
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
              getFormattedTime(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10,),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }
}
