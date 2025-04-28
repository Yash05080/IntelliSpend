import 'package:finance_manager_app/pages/Stats/charts/weekday.dart';
import 'package:finance_manager_app/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming HexColor is defined elsewhere in your app
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class AnalyticsDashboardScreen extends StatefulWidget {
  final String userId;

  const AnalyticsDashboardScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _AnalyticsDashboardScreenState createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final _analyticsService = AnalyticsService();
  
  // Data variables
  List<WeekdayExpense> _weekdayExpenses = [];
  List<CategoryAverage> _catAvg = [];
  List<MonthlyExpense> _monthlyExpenses = [];
  List<ExpenseDayData> _movingAvgData = [];
  List<Anomaly> _anoms = [];
  List<CategoryCount> _catCnt = [];
  List<CategoryStats> _catStats = [];
  List<ForecastPoint> _forecast = [];
  
  // Filter variables
  DateTime _startDate = DateTime.now().subtract(Duration(days: 90));
  DateTime _endDate = DateTime.now();
  List<String>? _selectedCategories;
  bool _isLoading = true;
  
  // Theme colors
  final Color bgColor = HexColor("232842"); // light navy blue
  final Color textColor = HexColor("FFFFFF"); // white
  final Color primaryColor = HexColor("F2C341"); // golden yellow  
  final Color secondaryColor = HexColor("f1a410"); // orange
  final Color tertiaryColor = HexColor("f3696e"); // coral pink
  final Color outlineColor = HexColor("f1a410"); // orange

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weekdayExpenses = await _analyticsService.getSpendingByWeekdayFiltered(
        userId: widget.userId, 
        startDate: _startDate, 
        endDate: _endDate,
        categories: _selectedCategories
      );
      
      final catAvg = await _analyticsService.getAverageSpendPerCategoryFiltered(
        userId: widget.userId,
        startDate: _startDate,
        endDate: _endDate,
        categories: _selectedCategories
      );
      
      final monthlyExpenses = await _analyticsService.getMonthlyExpenseTrend(widget.userId);
      final movingAvgData = await _analyticsService.getMovingAverage(widget.userId);
      final anoms = await _analyticsService.detectSpendingAnomalies(widget.userId);
      final catCnt = await _analyticsService.getTransactionCountPerCategory(widget.userId);
      final catStats = await _analyticsService.getCategoryMedianVariance(widget.userId);
      final forecast = await _analyticsService.forecastMonthlyExpenses(widget.userId, nextMonths: 3);

      setState(() {
        _weekdayExpenses = weekdayExpenses;
        _catAvg = catAvg;
        _monthlyExpenses = monthlyExpenses;
        _movingAvgData = movingAvgData;
        _anoms = anoms;
        _catCnt = catCnt;
        _catStats = catStats;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: tertiaryColor,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('Filter Analytics', style: TextStyle(color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date range pickers would go here
              // Category multi-select would go here
              Text("Date Range and Category filters", style: TextStyle(color: textColor)),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: secondaryColor)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Apply', style: TextStyle(color: HexColor("191d2d"))),
              onPressed: () {
                Navigator.pop(context);
                _loadData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return Scaffold(
      backgroundColor: HexColor("191d2d"),
      appBar: AppBar(
        backgroundColor: HexColor("191d2d"),
        title: Text("Financial Analytics", style: TextStyle(color: textColor)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Summary Card
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    
                    // Primary Analysis Section
                    _buildSectionHeader("Expense Analysis"),
                    _buildWeekdayExpenseChart(),
                    const SizedBox(height: 24),
                    
                    // Monthly Trend with Forecast
                    _buildSectionHeader("Weekly Trend"),
                    WeeklyExpenseChart(userId: uid),
                    const SizedBox(height: 24),
                    
                    // Category Analysis
                    _buildSectionHeader("Category Analysis"),
                    _buildCategoryAnalysisSection(),
                    //const SizedBox(height: 14),
                    
                    // Recent Activity & Insights
                    _buildSectionHeader("Insights & Anomalies"),
                    _buildInsightsSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final totalSpend = _monthlyExpenses.isEmpty ? 0.0 : 
        _monthlyExpenses.map((e) => e.total).reduce((a, b) => a + b);
    final avgPerMonth = _monthlyExpenses.isEmpty ? 0.0 : 
        totalSpend / _monthlyExpenses.length;
    
    return Card(
      elevation: 4,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outlineColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Financial Summary",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  "₹${totalSpend.toStringAsFixed(0)}",
                  "Total Analyzed",
                  Icons.account_balance_wallet,
                ),
                _buildSummaryItem(
                  "₹${avgPerMonth.toStringAsFixed(0)}",
                  "Monthly Avg",
                  Icons.calendar_month,
                ),
                _buildSummaryItem(
                  "${_catAvg.length}",
                  "Categories",
                  Icons.category,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: outlineColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayExpenseChart() {
    // Convert weekday expenses to data points
    final weekdayOrder = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final Map<String, double> weekdayMap = {
      for (var exp in _weekdayExpenses) exp.weekday: exp.total
    };
    
    // Fill in any missing weekdays with 0
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < weekdayOrder.length; i++) {
      final weekday = weekdayOrder[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weekdayMap[weekday] ?? 0,
              color: weekday == "Sat" || weekday == "Sun" 
                  ? tertiaryColor
                  : primaryColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Card(
      color: bgColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily Spending Pattern",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "See which days you spend the most",
              style: TextStyle(color: outlineColor, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: barGroups.map((g) => g.barRods.first.toY).reduce(max) * 1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              "₹${value.toInt()}",
                              style: TextStyle(color: outlineColor, fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            weekdayOrder[value.toInt()],
                            style: TextStyle(
                              color: textColor, 
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: outlineColor.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendChart() {
    // Combine actual data and forecast
    final allData = [..._monthlyExpenses, ..._forecast];
    
    // Create line chart data
    final spots = _monthlyExpenses.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.total);
    }).toList();
    
    // Create forecast spots
    final forecastSpots = _forecast.asMap().entries.map((entry) {
      return FlSpot((_monthlyExpenses.length - 1 + entry.key + 1).toDouble(), entry.value.predicted);
    }).toList();

    return Card(
      color: bgColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Spending Trend",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Last 12 months with 3-month forecast",
              style: TextStyle(color: outlineColor, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot touchedSpot) {
        // Assuming 'bgColor' is a Color variable you have defined elsewhere
        return bgColor.withOpacity(0.8);
      },
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          final isForecast = index >= _monthlyExpenses.length;
                          final month = isForecast 
                              ? _forecast[index - _monthlyExpenses.length].period
                              : _monthlyExpenses[index].month;
                          final value = touchedSpot.y;
                          
                          return LineTooltipItem(
                            '$month: ₹${value.toStringAsFixed(0)}',
                            TextStyle(
                              color: isForecast ? secondaryColor : primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: outlineColor.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 3 != 0) return const SizedBox();
                          
                          final index = value.toInt();
                          if (index >= allData.length) return const SizedBox();
                          
                          final month = index < _monthlyExpenses.length
                              ? _monthlyExpenses[index].month.substring(5) // Just show MM
                              : _forecast[index - _monthlyExpenses.length].period.substring(5);
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              month,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              "₹${value.toInt()}",
                              style: TextStyle(color: outlineColor, fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Actual data line
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primaryColor.withOpacity(0.1),
                      ),
                    ),
                    // Forecast line
                    if (forecastSpots.isNotEmpty)
                      LineChartBarData(
                        spots: forecastSpots,
                        isCurved: true,
                        color: secondaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        dashArray: [5, 5],
                        belowBarData: BarAreaData(
                          show: true,
                          color: secondaryColor.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Legend
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(primaryColor, "Actual"),
                  const SizedBox(width: 24),
                  _buildLegendItem(secondaryColor, "Forecast", isDashed: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAllCategoryAverages(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: HexColor("191d2d"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Category Averages",
                  style: TextStyle(
                    color: HexColor("FFFFFF"),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: HexColor("FFFFFF")),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 16, color: HexColor("f1a410").withOpacity(0.3)),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _catAvg.length,
                itemBuilder: (context, index) {
                  final cat = _catAvg[index];
                  return _buildCategoryListItem(
                    cat.category,
                    "₹${cat.average.toStringAsFixed(0)}",
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAllTransactionCounts(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: HexColor("191d2d"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Transaction Counts",
                  style: TextStyle(
                    color: HexColor("FFFFFF"),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: HexColor("FFFFFF")),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 16, color: HexColor("f1a410").withOpacity(0.3)),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _catCnt.length,
                itemBuilder: (context, index) {
                  final cat = _catCnt[index];
                  return _buildCategoryListItem(
                    cat.category,
                    "${cat.count}",
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAllCategoryStats(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: HexColor("191d2d"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Median & Variance",
                  style: TextStyle(
                    color: HexColor("FFFFFF"),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: HexColor("FFFFFF")),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 16, color: HexColor("f1a410").withOpacity(0.3)),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _catStats.length,
                itemBuilder: (context, index) {
                  final stat = _catStats[index];
                  return _buildCategoryStatsItem(
                    stat.category,
                    stat.median,
                    stat.variance,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildLegendItem(Color color, String label, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: isDashed ? 2 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed
              ? Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 3,
                      height: 2,
                      margin: EdgeInsets.only(right: index < 2 ? 2 : 0),
                      color: color,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

 Widget _buildCategoryAnalysisSection() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: BouncingScrollPhysics(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Category Averages
        _buildCategoryCard(
          "Avg. Spend per Category",
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: min(5, _catAvg.length),
            itemBuilder: (context, index) {
              final cat = _catAvg[index];
              return _buildCategoryListItem(
                cat.category,
                "₹${cat.average.toStringAsFixed(0)}",
                index,
              );
            },
          ),
          width: 250,
          onViewAllPressed: () => _showAllCategoryAverages(context),
        ),
        
        const SizedBox(width: 16),
        
        // Card 2: Transaction Counts
        _buildCategoryCard(
          "Transaction Count",
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: min(5, _catCnt.length),
            itemBuilder: (context, index) {
              final cat = _catCnt[index];
              return _buildCategoryListItem(
                cat.category,
                "${cat.count}",
                index,
              );
            },
          ),
          width: 250,
          onViewAllPressed: () => _showAllTransactionCounts(context),
        ),
        
        const SizedBox(width: 16),
        
        // Card 3: Category Stats
        _buildCategoryCard(
          "Median & Variance",
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: min(5, _catStats.length),
            itemBuilder: (context, index) {
              final stat = _catStats[index];
              return _buildCategoryStatsItem(
                stat.category,
                stat.median,
                stat.variance,
                index,
              );
            },
          ),
          width: 280,
          onViewAllPressed: () => _showAllCategoryStats(context),
        ),
      ],
    ),
  );
}

  Widget _buildCategoryCard(String title, Widget content, {
  required double width,
  required Function onViewAllPressed,
}) {
  return Container(
    width: width,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(height: 1, color: outlineColor.withOpacity(0.2)),
        content,
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => onViewAllPressed(),
              child: Text(
                "View All",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildCategoryListItem(String name, String value, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: outlineColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: [
                    primaryColor,
                    secondaryColor,
                    tertiaryColor,
                    primaryColor.withOpacity(0.7),
                    secondaryColor.withOpacity(0.7),
                  ][index % 5],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: HexColor("191d2d"),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: Text(
                  name,
                  style: TextStyle(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatsItem(String name, double median, double variance, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: outlineColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: [
                    primaryColor,
                    secondaryColor,
                    tertiaryColor,
                    primaryColor.withOpacity(0.7),
                    secondaryColor.withOpacity(0.7),
                  ][index % 5],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: HexColor("191d2d"),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: Text(
                  name,
                  style: TextStyle(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${median.toStringAsFixed(0)}",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "± ${sqrt(variance).toStringAsFixed(0)}",
                style: TextStyle(
                  color: outlineColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      children: [
        // Moving Average Chart
        Card(
          color: bgColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "7-Day Moving Average",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Smoothed trend of your daily expenses",
                  style: TextStyle(color: outlineColor, fontSize: 12),
                ),
                const SizedBox(height: 24),
                _buildMovingAverageChart(),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Anomalies Section
        if (_anoms.isNotEmpty)
          Card(
            color: bgColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: tertiaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "Spending Anomalies",
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Unusually high expense days",
                    style: TextStyle(color: outlineColor, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    min(3, _anoms.length),
                    (index) => _buildAnomalyItem(_anoms[index], index),
                  ),
                  if (_anoms.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: Text(
                          "View ${_anoms.length - 3} more anomalies",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMovingAverageChart() {
    if (_movingAvgData.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text("No trend data available",
            style: TextStyle(color: outlineColor)),
      );
    }

    // Create line chart spots
    final spots = _movingAvgData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.total);
    }).toList();

    // Find min and max values for better scaling
    final minY = _movingAvgData
            .map((d) => d.total)
            .reduce((a, b) => a < b ? a : b) *
        0.9;
    final maxY = _movingAvgData
            .map((d) => d.total)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) {
        // Assuming 'bgColor' is a Color variable you have defined elsewhere
        return bgColor.withOpacity(0.8);
      },
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  if (index >= 0 && index < _movingAvgData.length) {
                    final date = DateFormat('MMM d')
                        .format(_movingAvgData[index].date);
                    return LineTooltipItem(
                      '$date: ₹${touchedSpot.y.toStringAsFixed(0)}',
                      TextStyle(
                        color: tertiaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: outlineColor.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  // Show only a few dates for clarity
                  final index = value.toInt();
                  if (index % (_movingAvgData.length ~/ 4) != 0) {
                    return const SizedBox();
                  }
                  if (index >= 0 && index < _movingAvgData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd')
                            .format(_movingAvgData[index].date),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "₹${value.toInt()}",
                      style: TextStyle(color: outlineColor, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          minY: minY,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: tertiaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: tertiaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyItem(Anomaly anomaly, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tertiaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tertiaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tertiaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.trending_up_rounded,
                color: tertiaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM d, yyyy').format(anomaly.date),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Unusually high spending day",
                  style: TextStyle(
                    color: outlineColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹${anomaly.amount.toStringAsFixed(0)}",
            style: TextStyle(
              color: tertiaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Create a custom floating action button for quick insights
class InsightsFAB extends StatelessWidget {
  final VoidCallback onPressed;
  
  const InsightsFAB({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: HexColor("F2C341"),
      foregroundColor: HexColor("191d2d"),
      label: Row(
        children: [
          Icon(Icons.insights),
          SizedBox(width: 8),
          Text("Quick Insights"),
        ],
      ),
    );
  }
}

// Create a complete analytics home page
class AnalyticsHomePage extends StatefulWidget {
  final String userId;
  
  const AnalyticsHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _AnalyticsHomePageState createState() => _AnalyticsHomePageState();
}

class _AnalyticsHomePageState extends State<AnalyticsHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _showQuickInsights() {
    // Show bottom sheet with key insights
    showModalBottomSheet(
      context: context,
      backgroundColor: HexColor("232842"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildQuickInsightsSheet(),
    );
  }
  
  Widget _buildQuickInsightsSheet() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HexColor("FFFFFF").withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Quick Insights",
            style: TextStyle(
              color: HexColor("FFFFFF"),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildInsightTile(
            icon: Icons.trending_up,
            color: HexColor("F2C341"),
            title: "Highest Spending Day",
            content: "Your highest spending day is Friday",
          ),
          _buildInsightTile(
            icon: Icons.category,
            color: HexColor("f3696e"),
            title: "Top Category",
            content: "Most money goes to 'Dining Out'",
          ),
          _buildInsightTile(
            icon: Icons.calendar_today,
            color: HexColor("f1a410"),
            title: "Monthly Trend",
            content: "Your spending increased by 12% in April",
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(
                color: HexColor("F2C341"),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightTile({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: HexColor("FFFFFF"),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    color: HexColor("FFFFFF").withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("191d2d"),
      appBar: AppBar(
        backgroundColor: HexColor("191d2d"),
        elevation: 0,
        title: Text(
          "Finance Analytics",
          style: TextStyle(
            color: HexColor("FFFFFF"),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: HexColor("F2C341")),
            onPressed: () {
              // Show date filter
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: HexColor("FFFFFF")),
            onPressed: () {
              // Show more options
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: HexColor("F2C341"),
          tabs: [
            Tab(text: "Overview"),
            Tab(text: "Categories"),
            Tab(text: "Insights"),
          ],
          labelColor: HexColor("F2C341"),
          unselectedLabelColor: HexColor("FFFFFF").withOpacity(0.7),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          AnalyticsDashboardScreen(userId: widget.userId),
          
          // Categories Tab (a placeholder for now)
          Center(
            child: Text(
              "Category Analysis",
              style: TextStyle(color: HexColor("FFFFFF")),
            ),
          ),
          
          // Insights Tab (a placeholder for now)
          Center(
            child: Text(
              "Detailed Insights",
              style: TextStyle(color: HexColor("FFFFFF")),
            ),
          ),
        ],
      ),
      floatingActionButton: InsightsFAB(onPressed: _showQuickInsights),
    );
  }
}

// Updated implementation of specific components in your original design
// This shows how to upgrade the UI of certain sections

class CategoryAnalysisView extends StatelessWidget {
  final List<CategoryAverage> categoryAverages;
  final List<CategoryCount> categoryCounts;
  final List<CategoryStats> categoryStats;
  final Color textColor;
  final Color bgColor;
  final Color primaryColor;
  final Color outlineColor;

  const CategoryAnalysisView({
    Key? key,
    required this.categoryAverages,
    required this.categoryCounts,
    required this.categoryStats,
    required this.textColor,
    required this.bgColor,
    required this.primaryColor,
    required this.outlineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Category Analysis",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: primaryColor,
                      ),
                      labelColor: bgColor,
                      unselectedLabelColor: textColor,
                      tabs: [
                        Tab(text: "Averages"),
                        Tab(text: "Count"),
                        Tab(text: "Stats"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        // Averages Tab
                        ListView.builder(
                          itemCount: categoryAverages.length,
                          itemBuilder: (context, index) {
                            final cat = categoryAverages[index];
                            return _buildEnhancedListTile(
                              title: cat.category,
                              value: "₹${cat.average.toStringAsFixed(2)}",
                              index: index,
                            );
                          },
                        ),
                        
                        // Count Tab
                        ListView.builder(
                          itemCount: categoryCounts.length,
                          itemBuilder: (context, index) {
                            final cat = categoryCounts[index];
                            return _buildEnhancedListTile(
                              title: cat.category,
                              value: "${cat.count}",
                              index: index,
                            );
                          },
                        ),
                        
                        // Stats Tab
                        ListView.builder(
                          itemCount: categoryStats.length,
                          itemBuilder: (context, index) {
                            final stat = categoryStats[index];
                            return _buildEnhancedListTile(
                              title: stat.category,
                              value: "₹${stat.median.toStringAsFixed(2)}",
                              subtitle: "Var: ${stat.variance.toStringAsFixed(2)}",
                              index: index,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnhancedListTile({
    required String title,
    required String value,
    String? subtitle,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: bgColor.withOpacity(0.3),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: outlineColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Sample implementation of an animated pie chart for category distribution
class CategoryDistributionChart extends StatelessWidget {
  final List<CategoryAverage> categories;
  final Color bgColor;
  final Color textColor;
  
  const CategoryDistributionChart({
    Key? key,
    required this.categories,
    required this.bgColor,
    required this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Use only top 5 categories for the chart
    final topCategories = categories.take(5).toList();
    
    // Calculate the total for percentage
    final total = topCategories.fold(
      0.0, 
      (sum, item) => sum + item.average
    );
    
    // Generate pie sections
    final sections = topCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final percent = item.average / total;
      
      // Colors for the pie sections
      final colors = [
        HexColor("F2C341"), // primary
        HexColor("f1a410"), // secondary
        HexColor("f3696e"), // tertiary
        HexColor("F2C341").withOpacity(0.7),
        HexColor("f1a410").withOpacity(0.7),
      ];
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.average,
        title: '${(percent * 100).toStringAsFixed(0)}%',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
    }).toList();
    
    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category Distribution",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Legend
            Column(
              children: topCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final percent = item.average / total;
                
                // Colors matching the pie chart
                final colors = [
                  HexColor("F2C341"), // primary
                  HexColor("f1a410"), // secondary
                  HexColor("f3696e"), // tertiary
                  HexColor("F2C341").withOpacity(0.7),
                  HexColor("f1a410").withOpacity(0.7),
                ];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.category,
                          style: TextStyle(color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "₹${item.average.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(0)}%)",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}