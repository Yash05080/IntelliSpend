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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final result = await ChartService().fetchLast7DaysExpenses(userId);

      result.sort((a, b) => a.date.compareTo(b.date)); // sort by date

      final maxExpense = result.map((e) => e.total).fold(0.0, max);

      setState(() {
        _data = result;
        _maxY = maxExpense == 0 ? 1 : (maxExpense / 1000).ceilToDouble();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading chart data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(mainBarData()),
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
