import 'package:finance_manager_app/data/mydata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BatchResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> newTransactions;

  const BatchResultPage({Key? key, required this.newTransactions})
      : super(key: key);

  String _formatDate(String iso) =>
      DateFormat('MMM d, yyyy – hh:mm a').format(DateTime.parse(iso));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Transactions')),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: newTransactions.length,
        itemBuilder: (_, i) {
          final txn = newTransactions[i];
          final details = getCategoryDetails(txn['category']);
          // cycle through a list of highlight colors—or alternate:
          final highlight = i % 2 == 0 ? details['color'] : details['color'].withOpacity(0.7);

          return Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: highlight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: details['color'],
                child: details['icon'],
              ),
              title: Text(
                txn['title'] ?? '',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${_formatDate(txn['date'])}\n${txn['description']}',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                txn['amount'].toStringAsFixed(2),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
