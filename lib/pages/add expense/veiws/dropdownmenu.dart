import 'package:finance_manager_app/data/mydata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryDropdown extends StatefulWidget {
  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  // Initial selected category
  String selectedCategory = 'Food';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCategory,
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
              SizedBox(
                width: 10,
              ),
              Text(
                data['name'],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cool'),
              ),
            ],
          ),
        );
      }).toList(),
      hint: Text('Select Category'),
    );
  }
}
