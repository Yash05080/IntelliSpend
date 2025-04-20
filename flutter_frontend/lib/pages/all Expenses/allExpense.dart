// ignore: file_names
import 'package:finance_manager_app/data/category.dart';
import 'package:finance_manager_app/data/mydata.dart';
import 'package:finance_manager_app/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllExpense extends StatefulWidget {
  const AllExpense({super.key});

  @override
  State<AllExpense> createState() => _AllExpenseState();
}

class _AllExpenseState extends State<AllExpense> {
  List<Map<String, dynamic>> allTransactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  bool isLoading = true;

  String? selectedCategory;
  DateTime? selectedDate;

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

  @override
  void initState() {
    super.initState();
    fetchAllTransactions();
  }

  void fetchAllTransactions() async {
    try {
      final provider = TransactionProvider();
      await provider.loadTransactions();
      final transactions = provider.transactions;

      setState(() {
        allTransactions = transactions;
        filteredTransactions = transactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching transactions: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void applyFilters() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final allTransactions = provider.transactions;

    filteredTransactions = allTransactions.where((txn) {
      final txnDate = DateTime.parse(txn['date']); // Parses date string
      final matchesCategory =
          selectedCategory == 'All' || txn['category'] == selectedCategory;

      final matchesDate = selectedDate == null ||
          (txnDate.year == selectedDate!.year &&
              txnDate.month == selectedDate!.month &&
              txnDate.day == selectedDate!.day);

      return matchesCategory && matchesDate;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        backgroundColor: HexColor("34394b"),
        elevation: 0,
      ),
      backgroundColor: HexColor("23262e"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allTransactions.isEmpty
              ? const Center(
                  child: Text(
                    "No transactions yet.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: selectedCategory,
                            dropdownColor: HexColor("34394b"),
                            hint: const Text(
                              "Filter Category",
                              style: TextStyle(color: Colors.white70),
                            ),
                            items: categoryList.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                                applyFilters();
                              });
                            },
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogBackgroundColor: const Color(
                                          0xFF34394B), // 🎯 Custom background color
                                      colorScheme: ColorScheme.dark(
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .secondary, // Header color
                                        onPrimary:
                                            Colors.white, // Header text color
                                        surface: const Color(
                                            0xFF34394B), // Calendar background
                                        onSurface: Colors.white, // Text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.w800),
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
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                  applyFilters();
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range,
                                color: Colors.white),
                            label: Text(
                              selectedDate != null
                                  ? DateFormat('MMM d').format(selectedDate!)
                                  : 'Filter Date',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await Provider.of<TransactionProvider>(context,
                                    listen: false)
                                .loadTransactions();
                            fetchAllTransactions(); // Reload data and re-apply filters
                          },
                          child: ListView.builder(
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final expense = filteredTransactions[index];
                              var categoryDetails =
                                  getCategoryDetails(expense['category']);

                              return Card(
                                color: HexColor("34394b"),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                    expense['title'] ?? 'Expense',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            formatDate(expense['date']),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  217, 223, 223, 223),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formatTime(expense['date']),
                                            style: TextStyle(
                                              color: Colors.blueGrey[300],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        expense['description'] ?? '',
                                        style: TextStyle(
                                          color: Colors.blueGrey[200],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "${expense['amount']}",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                      ),
                    ],
                  ),
                ),
    );
  }
}
