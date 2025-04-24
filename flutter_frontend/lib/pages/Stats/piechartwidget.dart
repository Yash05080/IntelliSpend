import 'package:finance_manager_app/pages/Stats/piechart.dart';
import 'package:flutter/material.dart';
import 'package:finance_manager_app/services/transaction_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PieChartWidgetWrapper extends StatefulWidget {
  const PieChartWidgetWrapper({super.key});

  @override
  State<PieChartWidgetWrapper> createState() => _PieChartWidgetWrapperState();
}

class _PieChartWidgetWrapperState extends State<PieChartWidgetWrapper> {
  Map<String, double> categoryData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final data = await TransactionService().getExpenseByCategory(userId);
    setState(() {
      categoryData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (categoryData.isEmpty) {
      return const Center(child: Text("No expense data to show"));
    }

    return PieChartWidget(categoryData: categoryData);
  }
}
