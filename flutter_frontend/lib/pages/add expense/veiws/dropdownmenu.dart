import 'package:finance_manager_app/data/mydata.dart';
import 'package:flutter/material.dart';


class CategoryDropdown extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const CategoryDropdown({super.key, this.onChanged});

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String selectedCategory = 'Food';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCategory,
      dropdownColor: Theme.of(context).colorScheme.background,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedCategory = newValue;
          });
          widget.onChanged?.call(newValue);
        }
      },
      items: DataCategories.map<DropdownMenuItem<String>>((data) {
        return DropdownMenuItem<String>(
          value: data['name'],
          child: Row(
            children: [
              data['icon'],
              const SizedBox(width: 12),
              Text(
                data['name'],
                style: TextStyle(
                  color: data['color'],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cool',
                ),
              ),
            ],
          ),
        );
      }).toList(),
      hint: const Text('Select Category'),
    );
  }
}
