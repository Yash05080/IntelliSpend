// lib/pages/Stats/charts/monthlychartwidget.dart

import 'package:finance_manager_app/pages/Stats/charts/monthlychartwidget.dart';
import 'package:flutter/material.dart';
import 'package:finance_manager_app/services/analytics_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlyTrendChartWrapper extends StatefulWidget {
  const MonthlyTrendChartWrapper({super.key});

  @override
  State<MonthlyTrendChartWrapper> createState() => _MonthlyTrendChartWrapperState();
}

class _MonthlyTrendChartWrapperState extends State<MonthlyTrendChartWrapper> {
  List<MonthlyExpense> _actual = [];
  List<ExpenseDayData> _movingAvg = [];
  List<ForecastPoint> _forecast = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = "User not authenticated";
          _loading = false;
        });
        return;
      }

      final userId = user.id;
      final svc = AnalyticsService();

      // Load data in parallel for better performance
      final results = await Future.wait([
        svc.getMonthlyExpenseTrend(userId),
        svc.getMovingAverage(userId, windowDays: 7),
        svc.forecastMonthlyExpenses(userId, nextMonths: 2),
      ]);

      if (mounted) {
        setState(() {
          _actual = results[0] as List<MonthlyExpense>;
          _movingAvg = results[1] as List<ExpenseDayData>;
          _forecast = results[2] as List<ForecastPoint>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load data: ${e.toString()}";
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadData();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_actual.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No monthly expense data available yet. Add some transactions to see your spending trends.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MonthlyTrendChart(
        actual: _actual,
        movingAverage: _movingAvg,
        forecast: _forecast,
        height: 300,
      ),
    );
  }
}