import 'package:finance_manager_app/data/mydata.dart';
import 'package:flutter/material.dart';

class CategoryDropdown extends StatefulWidget {
  const CategoryDropdown({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  // Initial selected category
  String selectedCategory = 'Food';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCategory,
      dropdownColor: Theme.of(context).colorScheme.background,
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue!;
        });
      },
      items: DataCategories.map<DropdownMenuItem<String>>((data) {
        return DropdownMenuItem<String>(
          value: data['name'],
          child: Row(
            children: [
              // The small colored dot before the name
              data['icon'],
              const SizedBox(
                width: 10,
              ),
              Text(
                data['name'],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cool'),
              ),
            ],
          ),
        );
      }).toList(),
      hint: const Text('Select Category'),
    );
  }
}
