import 'dart:ui';

import 'package:finance_manager_app/data/mydata.dart';
import 'package:finance_manager_app/pages/Home/veiws/componants/balancecard.dart';
import 'package:finance_manager_app/pages/all%20Expenses/allExpense.dart';
import 'package:finance_manager_app/providers/transaction_provider.dart';
import 'package:finance_manager_app/services/transaction_service.dart';
import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  Icon _getActionIcon(String? action) {
    switch (action) {
      case 'credit':
        return const Icon(Icons.arrow_downward, color: Colors.green);
      case 'debit':
        return const Icon(Icons.arrow_upward, color: Colors.red);
      case 'update':
        return const Icon(Icons.sync, color: Colors.amber);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final data = await _transactionService.fetchTransactions();
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching transactions: $e')),
      );
    }
  }

  String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String formatTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return "Invalid Time";
    }
  }

// log out option temparory
  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3), // dim background
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: Icon(Icons.logout, color: Colors.redAccent),
                      label: Text("Log Out"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "User";
    final initial = email.isNotEmpty ? email[0].toUpperCase() : "U";

    final provider = context.watch<TransactionProvider>();
    final txList = provider.transactions;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HexColor("F2C341"),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _showSettingsDialog,
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            //  Balance Card

            const BalanceCard(),

            const SizedBox(
              height: 40,
            ),

            // Transactions

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                // veiw all function

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllExpense()));
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey[400],
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            //transactions list

            Expanded(
              child: FutureBuilder(
                future: Supabase.instance.client
                    .from('balance')
                    .select()
                    .eq('user_id',
                        Supabase.instance.client.auth.currentUser!.id)
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                        child: Text("Error loading balance entries"));
                  }

                  final entries = snapshot.data as List<dynamic>;

                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, i) {
                      final entry = entries[i];
                      if (entry == null || entry is! Map<String, dynamic>) {
                        return const SizedBox();
                      }

                      final amount = entry['amount'] ?? 0;
                      final action = (entry['type'] ?? 'update') as String;
                      final date =
                          DateTime.parse(entry['created_at']).toLocal();
                      final icon = _getActionIcon(action);
                      final isCredit = action == 'credit';

                      return Card(
                        color: HexColor(
                            "1f2333"), // slightly lighter than background for contrast
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: isCredit
                                ? HexColor("F2C341").withOpacity(0.2)
                                : HexColor("f3696e").withOpacity(0.2),
                            child: icon,
                          ),
                          title: Text(
                            "₹$amount",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HexColor("FFFFFF"), // onSurface
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${action[0].toUpperCase()}${action.substring(1)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      HexColor("f1a410"), // outline (subtext)
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                        children: [
                                          Text(
                                            formatDate(date.toString()),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  217, 223, 223, 223),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formatTime(date.toString()),
                                            style: TextStyle(
                                              color: Colors.blueGrey[300],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
