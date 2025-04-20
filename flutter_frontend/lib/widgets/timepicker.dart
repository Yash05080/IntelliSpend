import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final ValueChanged<TimeOfDay>? onTimeSelected;

  const TimePickerWidget({super.key, this.onTimeSelected});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onTimeSelected?.call(picked); // 🔥 Callback to parent
    }
  }

  String getFormattedTime() {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickTime(context),
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
              getFormattedTime(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }
}
