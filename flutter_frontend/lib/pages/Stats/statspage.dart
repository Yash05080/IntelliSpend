import 'package:finance_manager_app/pages/Stats/chartpage.dart';
import 'package:finance_manager_app/pages/Stats/charts/monthlychart.dart';
import 'package:finance_manager_app/pages/Stats/charts/weekday.dart';
import 'package:flutter/material.dart';
import 'package:finance_manager_app/pages/Stats/charts/chart.dart';              // Bar chart
import 'package:finance_manager_app/pages/Stats/charts/piechartwidget.dart';     // Pie chart
import 'package:hexcolor/hexcolor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bgLight = HexColor("2a3042"); // lighter shade of #191d2d
    final uid = Supabase.instance.client.auth.currentUser!.id;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Analytics",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // 📊 Bar Chart Container
              Container(
                width: screenWidth,
                height: screenWidth,
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 30, 12, 12),
                  child: MyChart(),
                ),
              ),
              const SizedBox(height: 30),

              // 🥧 Pie Chart Container
              Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
                child: const PieChartWidgetWrapper(),
              ),
              const SizedBox(height: 30),

              // 📈 Monthly Trend Line Chart Container
              GestureDetector(
                onTap: () {
  final uid = Supabase.instance.client.auth.currentUser!.id;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AnalyticsDetailPage(userId: uid),
    ),
  );
},

                child: Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
                  child:WeeklyExpenseChart(userId: uid,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
