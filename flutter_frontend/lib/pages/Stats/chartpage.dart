// lib/pages/Stats/analytics_detail_page.dart

import 'package:finance_manager_app/pages/Stats/charts/chart.dart';
import 'package:finance_manager_app/pages/Stats/charts/monthlychartwidget.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:finance_manager_app/services/analytics_service.dart';
import 'charts/piechartwidget.dart';

class AnalyticsDetailPage extends StatefulWidget {
  final String userId;
  const AnalyticsDetailPage({super.key, required this.userId});

  @override
  State<AnalyticsDetailPage> createState() => _AnalyticsDetailPageState();
}

class _AnalyticsDetailPageState extends State<AnalyticsDetailPage> {
  late Future<void> _loadingFuture;

  // Data holders
  List<MonthlyExpense> _monthly = [];
  List<ExpenseDayData> _ma = [];
  List<ForecastPoint> _forecast = [];
  List<WeekdayExpense> _weekday = [];
  List<CategoryAverage> _catAvg = [];
  List<CategoryCount> _catCnt = [];
  List<CategoryStats> _catStats = [];
  List<Anomaly> _anoms = [];

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadAll();
  }

  Future<void> _loadAll() async {
    final svc = AnalyticsService();
    final uid = widget.userId;
    _monthly = await svc.getMonthlyExpenseTrend(uid);
    _ma = await svc.getMovingAverage(uid);
    _forecast = await svc.forecastMonthlyExpenses(uid, nextMonths: 1);
    _weekday = await svc.getSpendingByWeekday(uid);
    _catAvg = await svc.getAverageSpendPerCategory(uid);
    _catCnt = await svc.getTransactionCountPerCategory(uid);
    _catStats = await svc.getCategoryMedianVariance(uid);
    _anoms = await svc.detectSpendingAnomalies(uid);
  }

  @override
  Widget build(BuildContext context) {
    final bg = HexColor("232842");
    final textColor = Colors.white;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Detailed Analytics"),
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Trend
                const Text("Monthly Trend",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                MonthlyTrendChart(
                  actual: _monthly,
                  movingAverage: _ma,
                  forecast: _forecast,
                  height: 350,
                ),
                const SizedBox(height: 24),

                // 3) Category Averages
                const Text("Avg. per Category",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                ..._catAvg.map((c) => ListTile(
                      title:
                          Text(c.category, style: TextStyle(color: textColor)),
                      trailing: Text("₹${c.average.toStringAsFixed(2)}",
                          style: TextStyle(color: textColor)),
                    )),

                const SizedBox(height: 16),

                // 4) Transaction Counts
                const Text("Transactions per Category",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                ..._catCnt.map((c) => ListTile(
                      title:
                          Text(c.category, style: TextStyle(color: textColor)),
                      trailing: Text(c.count.toString(),
                          style: TextStyle(color: textColor)),
                    )),

                const SizedBox(height: 16),

                // 5) Median & Variance
                const Text("Category Stats (Median & Variance)",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                ..._catStats.map((c) => ListTile(
                      title:
                          Text(c.category, style: TextStyle(color: textColor)),
                      subtitle: Text(
                          "Median: ₹${c.median.toStringAsFixed(2)}, Var: ${c.variance.toStringAsFixed(2)}",
                          style: TextStyle(color: textColor)),
                    )),

                const SizedBox(height: 16),

                // 6) Anomalies
                const Text("Anomalies (High-Spend Days)",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                ..._anoms.map((a) => ListTile(
                      title: Text(a.date.toIso8601String().split('T').first,
                          style: TextStyle(color: textColor)),
                      trailing: Text("₹${a.amount.toStringAsFixed(2)}",
                          style: TextStyle(color: textColor)),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
