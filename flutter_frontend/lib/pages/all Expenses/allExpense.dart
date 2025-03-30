// ignore: file_names
import 'package:finance_manager_app/data/mydata.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AllExpense extends StatelessWidget {
  const AllExpense({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        backgroundColor: HexColor("34394b"),
        elevation: 0,
      ),
      backgroundColor: HexColor("23262e"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: ListView.builder(
          
          itemCount: transactionsData.length,
          itemBuilder: (context, index) {
          var categoryDetails =
                      getCategoryDetails(transactionsData[index]['category']);

            final expense = transactionsData[index];
            return Card(
              color: HexColor("34394b"),
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: categoryDetails['color'],
                  radius: 25,
                  child: categoryDetails['icon'],
                ),
                title: Text(
                  expense['name'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense['date'],
                      style: TextStyle(
                        color: Colors.blueGrey[300],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      expense['description'],
                      style: TextStyle(
                        color: Colors.blueGrey[200],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  expense['totalamount'] ?? " Nil ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
