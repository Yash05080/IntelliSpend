import 'dart:math';

import 'package:finance_manager_app/models/expensemodel.dart';
import 'package:finance_manager_app/services/chart_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  List<ExpenseDayData> _data = [];
  double _maxY = 1;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not authenticated';
      });
      return;
    }

    try {
      print("Fetching chart data for user: $userId");
      // Generate the last 7 days of dates regardless of what comes from the service
      final List<DateTime> last7Days = [];
      final Map<String, ExpenseDayData> expensesByDate = {};
      
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        last7Days.add(date);
        
        // Initialize with zero expenses
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        expensesByDate[dateStr] = ExpenseDayData(
          date: date,
          total: 0.0,
        );
      }
      
      // Try to fetch data from the service
      try {
        final result = await ChartService().fetchLast7DaysExpenses(userId);
        print("Received ${result.length} expense records");
        
        // Fill in actual expense data
        for (var expense in result) {
          final dateStr = DateFormat('yyyy-MM-dd').format(expense.date);
          print("Processing expense for date: $dateStr");
          expensesByDate[dateStr] = expense;
        }
      } catch (serviceError) {
        print("Error from ChartService: $serviceError");
        // Continue with empty data rather than failing completely
      }
      
      // Convert the map to a sorted list
      final processedData = last7Days.map((date) {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        return expensesByDate[dateStr] ?? ExpenseDayData(date: date, total: 0.0);
      }).toList();
      
      print("Processed data: ${processedData.map((e) => '${DateFormat('yyyy-MM-dd').format(e.date)}: ${e.total}').join(', ')}");
      
      if (!mounted) return;
      
      final maxExpense = processedData.map((e) => e.total).fold(0.0, max);
      print("Max expense: $maxExpense");

      setState(() {
        _data = processedData;
        _maxY = maxExpense <= 0 ? 1 : (maxExpense / 1000).ceilToDouble();
        _isLoading = false;
      });
    } catch (e) {
      print("Critical error in chart: $e");
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load chart data';
        // Still show the last 7 days with zero values
        final now = DateTime.now();
        _data = List.generate(7, (i) {
          return ExpenseDayData(
            date: DateTime(now.year, now.month, now.day - (6 - i)),
            total: 0.0,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading expense data...")
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    if (_data.isEmpty) {
      return const Center(
        child: Text("No expense data available"),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Column(
        children: [
          Expanded(
            child: BarChart(mainBarData()),
          ),
          
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    final theme = Theme.of(context).colorScheme;

    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y / 1000,
        width: 14,
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [
            theme.tertiary,
            theme.secondary,
            theme.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: _maxY,
          color: Colors.grey.shade300,
        ),
      ),
    ]);
  }

  BarChartData mainBarData() {
    return BarChartData(
      barGroups: List.generate(_data.length, (i) {
        return makeGroupData(i, _data[i].total);
      }),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index < 0 || index >= _data.length) return const SizedBox();
              final date = _data[index].date;
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  DateFormat('dd\nMMM').format(date),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  "₹ ${(value * 1000).toInt()}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      maxY: _maxY,
    );
  }
}