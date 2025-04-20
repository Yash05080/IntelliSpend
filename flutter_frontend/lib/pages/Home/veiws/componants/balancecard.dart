import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchBalanceData();
  }

  Future<void> _fetchBalanceData() async {
    final response = await supabase
        .from('balance')
        .select()
        .order('created_at', ascending: true);

    double income = 0.0;
    double expense = 0.0;
    double balance = 0.0;

    for (var item in response) {
      final type = item['type'];
      final amount = (item['amount'] as num).toDouble();

      if (type == 'credit') {
        income += amount;
        balance += amount;
      } else if (type == 'debit') {
        expense += amount;
        balance -= amount;
      } else if (type == 'update') {
        balance = amount;
      }
    }

    setState(() {
      _income = income;
      _expense = expense;
      _balance = balance;
    });
  }

  void _showBalanceDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: HexColor("191d2d"), // dark navy blue
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile('Update Balance', 'update'),
            const Divider(color: Colors.white24),
            _buildOptionTile('Credit Amount', 'credit'),
            const Divider(color: Colors.white24),
            _buildOptionTile('Debit Amount', 'debit'),
          ],
        ),
      );
    },
  );
}

Widget _buildOptionTile(String title, String type) {
  return ListTile(
    title: Text(
      title,
      style: TextStyle(
        color: HexColor("FFFFFF"), // white
        fontWeight: FontWeight.bold,
      ),
    ),
    trailing: Icon(Icons.arrow_forward_ios, size: 18, color: HexColor("F2C341")), // golden yellow
    onTap: () async {
      Navigator.pop(context);
      final controller = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: HexColor("191d2d"),
          title: Text(title, style: TextStyle(color: HexColor("F2C341"))),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: HexColor("FFFFFF")),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: HexColor("f1a410")), // orange
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HexColor("f1a410")),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HexColor("f3696e")), // coral pink
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: HexColor("f3696e"))),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor("F2C341"), // golden yellow
                foregroundColor: Colors.black,
              ),
              child: const Text("Submit"),
              onPressed: () async {
                final input = controller.text.trim();
                if (input.isNotEmpty && double.tryParse(input) != null) {
                  final amount = double.parse(input);

                  await supabase.from('balance').insert({
                    'type': type,
                    'amount': amount,
                  });

                  Navigator.pop(context);
                  _fetchBalanceData();
                }
              },
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width / 2,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.primary,
          ],
          transform: const GradientRotation(pi / 8),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
            offset: const Offset(0, 8),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            offset: const Offset(0, 12),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () => _showBalanceDialog(context),
            child: Text(
              "₹ ${_balance.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniTile("Income", _income, Colors.green, Icons.arrow_downward),
                _buildMiniTile("Expenses", _expense, Colors.red, Icons.arrow_upward_outlined),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniTile(String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 26,
          decoration: const BoxDecoration(
            color: Colors.white54,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black)),
            Text("₹${amount.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
