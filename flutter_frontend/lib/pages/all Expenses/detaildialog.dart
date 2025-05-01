import 'package:finance_manager_app/data/mydata.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:finance_manager_app/data/category.dart';
import 'package:finance_manager_app/providers/transaction_provider.dart';

class ExpenseDetailDialog extends StatefulWidget {
  final Map<String, dynamic> expense;

  const ExpenseDetailDialog({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  State<ExpenseDetailDialog> createState() => _ExpenseDetailDialogState();
}

class _ExpenseDetailDialogState extends State<ExpenseDetailDialog> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  late String selectedCategory;
  late DateTime selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current expense data
    titleController =
        TextEditingController(text: widget.expense['title'] ?? '');
    amountController =
        TextEditingController(text: widget.expense['amount'].toString());
    descriptionController =
        TextEditingController(text: widget.expense['description'] ?? '');
    selectedCategory = widget.expense['category'];
    selectedDate = DateTime.parse(widget.expense['date']);
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _editExpense() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and amount are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      double newAmount = double.parse(amountController.text);
      double oldAmount = widget.expense['amount'].toDouble();

      await provider.updateTransaction(
        id: widget.expense['id'],
        title: titleController.text,
        amount: newAmount,
        category: selectedCategory,
        description: descriptionController.text,
        date: selectedDate,
        oldAmount: oldAmount,
      );

      if (mounted) {
        Navigator.of(context)
            .pop(true); // Return true to indicate successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update expense: $e")),
        );
      }
    }
  }

  void _deleteExpense() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor("34394b"),
        title: const Text(
          "Confirm Delete",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this expense?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.deleteTransaction(
        widget.expense['id'],
        widget.expense['amount'],
      );

      if (mounted) {
        Navigator.of(context)
            .pop(true); // Return true to indicate successful deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense deleted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete expense: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var categoryDetails = getCategoryDetails(selectedCategory);

    return Dialog(
      backgroundColor: HexColor("34394b"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Expense Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),

              // Category selection
              Text(
                "Category",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: HexColor("23262e"),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    dropdownColor: HexColor("23262e"),
                    items: categoryList.map((category) {
                      final details = getCategoryDetails(category);
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: details['color'],
                              radius: 14,
                              child: details['icon'],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title field
              Text(
                "Title",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor("23262e"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Amount field
              Text(
                "Amount",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor("23262e"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Description field
              Text(
                "Description",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor("23262e"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date picker
              Text(
                "Date",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor: const Color(0xFF34394B),
                          colorScheme: ColorScheme.dark(
                            primary: Theme.of(context).colorScheme.secondary,
                            onPrimary: Colors.white,
                            surface: const Color(0xFF34394B),
                            onSurface: Colors.white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w800),
                              foregroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    // Preserve the time from the original date
                    setState(() {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        selectedDate.hour,
                        selectedDate.minute,
                      );
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    color: HexColor("23262e"),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Time picker
              Text(
                "Time",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor: const Color(0xFF34394B),
                          colorScheme: ColorScheme.dark(
                            primary: Theme.of(context).colorScheme.secondary,
                            onPrimary: Colors.white,
                            surface: const Color(0xFF34394B),
                            onSurface: Colors.white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.w800),
                              foregroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    color: HexColor("23262e"),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(Icons.access_time, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _deleteExpense,
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _editExpense,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(isLoading ? "Saving..." : "Save Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.background,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
