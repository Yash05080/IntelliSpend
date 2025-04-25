import 'package:finance_manager_app/data/category.dart';
import 'package:finance_manager_app/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WeeklyExpenseChart extends StatefulWidget {
  final String userId;
  const WeeklyExpenseChart({Key? key, required this.userId}) : super(key: key);

  @override
  State<WeeklyExpenseChart> createState() => _WeeklyExpenseChartState();
}

class _WeeklyExpenseChartState extends State<WeeklyExpenseChart> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<FlSpot> _spots = [];
  double _maxY = 1000;
  List<WeeklyExpenseData> _weeklyData = [];
  final analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final startDate =
          now.subtract(const Duration(days: 30)); // Get data for past 30 days
      final endDate = now;

      List<WeekdayExpense> data;
      if (_selectedCategory == 'All') {
        data = await analyticsService.getSpendingByWeekdayFiltered(
          userId: widget.userId,
          startDate: startDate,
          endDate: endDate,
          categories: null,
        );
      } else {
        data = await analyticsService.getSpendingByWeekdayFiltered(
          userId: widget.userId,
          startDate: startDate,
          endDate: endDate,
          categories: [_selectedCategory],
        );
      }

      _processData(data);
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chart data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processData(List<WeekdayExpense> data) {
  // Map weekday names to indexes
  final weekdayMap = {
    'Mon': 0, 'Tue': 1, 'Wed': 2, 'Thu': 3, 'Fri': 4, 'Sat': 5, 'Sun': 6
  };

  // Create a list with all weekdays (even ones without data)
  List<WeeklyExpenseData> allWeekdays = [];
  for (var entry in weekdayMap.entries) {
    // Find the data for this weekday or use 0 if not found
    WeekdayExpense? weekdayData = data.firstWhere(
      (e) => e.weekday == entry.key,
      orElse: () => WeekdayExpense(weekday: entry.key, total: 0),
    );
    
    allWeekdays.add(WeeklyExpenseData(
      weekdayIndex: entry.value,
      weekday: entry.key,
      amount: weekdayData.total,
    ));
  }
  
  // Sort by weekday index
  allWeekdays.sort((a, b) => a.weekdayIndex.compareTo(b.weekdayIndex));
  _weeklyData = allWeekdays;
  
  // Create spots for the chart
  _spots = _weeklyData
      .mapIndexed((index, data) => FlSpot(index.toDouble(), data.amount))
      .toList();

  // Find the maximum Y value for the chart scale
  if (_spots.isNotEmpty) {
    _maxY = _spots.map((spot) => spot.y).reduce((max, y) => y > max ? y : max) * 1.2;
    _maxY = _maxY < 100 ? 100 : _maxY; // Set minimum scale
  } else {
    _maxY = 100; // Default scale if no data
  }
}

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null && newCategory != _selectedCategory) {
      setState(() {
        _selectedCategory = newCategory;
      });
      _fetchData();
    }
  }

  @override
Widget build(BuildContext context) {
  final colors = {
    'background': HexColor("191d2d"), // dark navy blue
    'graphBackground': HexColor("1E2235"), // lighter shade of navy
    'onSurface': HexColor("FFFFFF"), // white (text)
    'primary': HexColor("F2C341"), // golden yellow
    'secondary': HexColor("f1a410"), // orange
    'tertiary': HexColor("f3696e"), // coral pink
    'outline': HexColor("f1a410"), // orange (subtext)
  };

  return Card(
    elevation: 4,
    color: colors['background'],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Weekly Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors['onSurface'],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: colors['background'],
                  textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: colors['onSurface'],
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: _onCategoryChanged,
                  dropdownColor: colors['background'],
                  style: TextStyle(color: colors['onSurface']),
                  icon: Icon(Icons.arrow_drop_down, color: colors['primary']),
                  underline: Container(
                    height: 2,
                    color: colors['primary'],
                  ),
                  items: categoryList.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track your spending patterns through the week',
            style: TextStyle(
              color: colors['outline'],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? Center(child: CircularProgressIndicator(color: colors['primary']))
              : SizedBox(
                  height: 250,
                  child: _spots.isEmpty
                      ? Center(child: Text('No data available for selected category', 
                          style: TextStyle(color: colors['onSurface'])))
                      : LineChart(_buildLineChart()),
                ),
          const SizedBox(height: 16),
          _buildLegend(colors),
        ],
      ),
    ),
  );
}

Widget _buildLegend(Map<String, Color> colors) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: colors['primary'],
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        _selectedCategory == 'All' 
            ? 'Total Expenses' 
            : '$_selectedCategory Expenses',
        style: TextStyle(fontSize: 12, color: colors['onSurface']),
      ),
    ],
  );
}
  // Then in your _buildLineChart method:
  LineChartData _buildLineChart() {
    final colors = {
      'background': HexColor("191d2d"), // dark navy blue
      'graphBackground': HexColor("1E2235"), // lighter shade of navy
      'onSurface': HexColor("FFFFFF"), // white (text)
      'primary': HexColor("F2C341"), // golden yellow
      'secondary': HexColor("f1a410"), // orange
      'tertiary': HexColor("f3696e"), // coral pink
      'outline': HexColor("f1a410"), // orange (subtext)
    };

    return LineChartData(
      backgroundColor: colors['graphBackground'],
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _maxY / 5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colors['onSurface']!.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: colors['onSurface']!.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // Only show labels for values that directly correspond to our data points
              if (value.toInt() >= 0 && value.toInt() < _weeklyData.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _weeklyData[value.toInt()].weekday,
                    style: TextStyle(
                      color: colors['onSurface'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _maxY / 5,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              final formatter = NumberFormat.compact();
              return Text(
                formatter.format(value),
                style: TextStyle(
                  color: colors['onSurface'],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false, // Remove the border
      ),
      // Set exact boundaries to prevent duplicate labels
      minX: 0,
      maxX: _spots.length - 1.0,
      minY: 0,
      maxY: _maxY,
      lineBarsData: [
        LineChartBarData(
          spots: _spots,
          isCurved: true,
          color: colors['primary'],
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 5,
                color: colors['primary']!,
                strokeWidth: 2,
                strokeColor: colors['onSurface']!,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: colors['primary']!.withOpacity(0.3),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) {
            // Assuming 'bgColor' is a Color variable you have defined elsewhere
            return colors['secondary']!.withOpacity(0.8);
          },
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot spot) {
              final index = spot.x.toInt();
              final formatter = NumberFormat.currency(symbol: '\$');

              if (index >= 0 && index < _weeklyData.length) {
                return LineTooltipItem(
                  '${_weeklyData[index].weekday}\n${formatter.format(spot.y)}',
                  TextStyle(
                      color: colors['onSurface'], fontWeight: FontWeight.bold),
                );
              }
              return null;
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  
}

class WeeklyExpenseData {
  final int weekdayIndex;
  final String weekday;
  final double amount;

  WeeklyExpenseData(
      {required this.weekdayIndex,
      required this.weekday,
      required this.amount});
}

// Main page that hosts the chart
class ExpenseAnalyticsPage extends StatelessWidget {
  const ExpenseAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense Analytics')),
        body: const Center(child: Text('You need to log in first')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyExpenseChart(userId: userId),
            const SizedBox(height: 24),
            // Here you can add more analytics components as needed
          ],
        ),
      ),
    );
  }
}
