import 'package:finance_manager_app/pages/Stats/charts/chart.dart';
import 'package:finance_manager_app/pages/Stats/charts/monthlychartwidget.dart';
import 'package:finance_manager_app/pages/Stats/charts/weekday.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:finance_manager_app/services/analytics_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  // Date filters
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<String>? _selectedCategories;

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
    _forecast = await svc.forecastMonthlyExpenses(uid, nextMonths: 3);
    _weekday = await svc.getSpendingByWeekday(uid);
    _catAvg = await svc.getAverageSpendPerCategory(uid);
    _catCnt = await svc.getTransactionCountPerCategory(uid);
    _catStats = await svc.getCategoryMedianVariance(uid);
    _anoms = await svc.detectSpendingAnomalies(uid);
  }

  Future<void> _applyFilters() async {
    final svc = AnalyticsService();
    setState(() {
      _loadingFuture = Future.wait([
        svc.getSpendingByWeekdayFiltered(
          userId: widget.userId,
          startDate: _startDate,
          endDate: _endDate,
          categories: _selectedCategories,
        ).then((value) => _weekday = value),
        svc.getAverageSpendPerCategoryFiltered(
          userId: widget.userId,
          startDate: _startDate,
          endDate: _endDate,
          categories: _selectedCategories,
        ).then((value) => _catAvg = value),
      ]);
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime tempStartDate = _startDate;
        DateTime tempEndDate = _endDate;
        return AlertDialog(
          backgroundColor: HexColor("2a3042"),
          title: const Text("Filter Data", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePickerRow("Start Date", tempStartDate, (date) {
                tempStartDate = date;
              }),
              const SizedBox(height: 8),
              _buildDatePickerRow("End Date", tempEndDate, (date) {
                tempEndDate = date;
              }),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDatePickerRow(String label, DateTime initialDate, Function(DateTime) onDateChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        TextButton(
          child: Text(
            "${initialDate.day}/${initialDate.month}/${initialDate.year}",
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: HexColor("6a74cf"),
                      onPrimary: Colors.white,
                      surface: HexColor("2a3042"),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateChanged(date);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bgLight = HexColor("2a3042"); // lighter shade of #191d2d
    final accent = HexColor("6a74cf"); // purple accent
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final bg = HexColor("232842");
    final textColor = Colors.white;
    final subtitleColor = Colors.white70;
    
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("Detailed Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: accent),
                  const SizedBox(height: 16),
                  Text(
                    "Loading analytics...",
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Monthly Trend Section
                _buildSectionHeader("Monthly Trend", Icons.trending_up),
                const SizedBox(height: 12),
                Container(
                  width: screenWidth - 32, // Adjust width to account for padding
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
                  child: WeeklyExpenseChart(userId: uid),
                ),
                
                if (_forecast.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Future Forecast",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var f in _forecast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatMonth(f.period),
                                  style: TextStyle(color: textColor),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "₹${f.predicted.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_right,
                                      color: Colors.white54,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),

                // 2) Weekday Spending
                _buildSectionHeader("Weekday Spending", Icons.calendar_today),
                const SizedBox(height: 12),
                _buildWeekdayBarChart(_weekday, bgLight, accent),
                const SizedBox(height: 24),

                // 3) Category Analysis
                _buildSectionHeader("Category Analysis", Icons.category),
                const SizedBox(height: 12),
                _buildTabView(
                  [
                    _buildCategoryAverageTab(_catAvg, textColor, accent),
                    _buildCategoryCountTab(_catCnt, textColor, accent, screenWidth),
                    _buildCategoryStatsTab(_catStats, textColor, subtitleColor),
                  ],
                  bgLight,
                  height: 260, // Fixed height to prevent overflow
                ),
                const SizedBox(height: 24),

                // 4) Anomalies
                if (_anoms.isNotEmpty) ...[
                  _buildSectionHeader("Spending Anomalies", Icons.warning_amber_rounded),
                  const SizedBox(height: 12),
                  _buildAnomaliesCard(_anoms, textColor, accent),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatMonth(String periodStr) {
    final parts = periodStr.split('-');
    final Map<String, String> months = {
      '01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr',
      '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Aug',
      '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dec'
    };
    return "${months[parts[1]] ?? parts[1]} ${parts[0]}";
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HexColor("2a3042"),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 4),
      child: child,
    );
  }

  Widget _buildWeekdayBarChart(List<WeekdayExpense> data, Color bgColor, Color accentColor) {
    // Handle empty data case
    if (data.isEmpty) {
      return _buildCard(
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "No weekday data available",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }
    
    final double maxValue = data.fold(0, (max, item) => item.total > max ? item.total : max);
    
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending by Day of Week",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((day) {
                // Prevent division by zero
                final height = maxValue > 0 ? 160 * (day.total / maxValue) : 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "₹${day.total.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24, // Slightly smaller width to prevent overflow
                      height: height.clamp(0.0, 150.0), // Ensure valid height
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            accentColor.withOpacity(0.4),
                            accentColor,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day.weekday,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(List<Widget> tabs, Color bgColor, {double height = 300}) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: "Averages"),
                    Tab(text: "Counts"),
                    Tab(text: "Stats"),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                SizedBox(
                  height: height,
                  child: TabBarView(
                    children: tabs,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAverageTab(List<CategoryAverage> data, Color textColor, Color accentColor) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No category data available",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.category,
                    style: TextStyle(color: textColor),
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                ),
                Text(
                  "₹${item.average.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCountTab(List<CategoryCount> data, Color textColor, Color accentColor, double screenWidth) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No category data available",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    
    final maxCount = data.fold(0, (max, item) => item.count > max ? item.count : max);
    // To prevent division by zero
    final safeMaxCount = maxCount > 0 ? maxCount : 1;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final progress = item.count / safeMaxCount;
          // Calculate safe width for the progress bar
          final safeWidth = (screenWidth - 100) * progress;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.category,
                        style: TextStyle(color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${item.count} txns",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Make sure width is not negative or too large
                    Container(
                      width: safeWidth.clamp(0.0, screenWidth - 100),
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryStatsTab(List<CategoryStats> data, Color textColor, Color subtitleColor) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No category stats available",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent text overflow
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Median",
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "₹${item.median.toStringAsFixed(2)}",
                            style: TextStyle(color: textColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Variance",
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            item.variance.toStringAsFixed(2),
                            style: TextStyle(color: textColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnomaliesCard(List<Anomaly> anomalies, Color textColor, Color accentColor) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Unusual Spending Detected",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Limit the number of anomalies shown to prevent the card from being too tall
          ...anomalies.take(5).map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(a.date),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "Higher than average",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${a.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )),
          // Show a "View More" button if there are more anomalies
          if (anomalies.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // Could navigate to a full list view of anomalies
                },
                child: Text(
                  "View ${anomalies.length - 5} more",
                  style: TextStyle(color: accentColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final Map<int, String> months = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
      5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
      9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    return "${date.day} ${months[date.month]} ${date.year}";
  }
}