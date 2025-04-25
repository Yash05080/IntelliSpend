// lib/pages/Stats/charts/monthly_trend_chart.dart

import 'package:finance_manager_app/services/analytics_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyExpense> actual;
  final List<ExpenseDayData> movingAverage;
  final List<ForecastPoint> forecast;
  final double height;

  const MonthlyTrendChart({
    super.key,
    required this.actual,
    required this.movingAverage,
    required this.forecast,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    // Colors
    final bgColor = HexColor("232842");
    final gold = HexColor("F2C341");
    final orange = HexColor("f1a410");
    final pink = HexColor("f3696e");
    final textColor = Colors.white;

    // No data case
    if (actual.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            "No monthly data available",
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ),
      );
    }

    // Parse months for better display
    final displayMonths = actual.map((m) {
      final parts = m.month.split('-');
      if (parts.length == 2) {
        return DateFormat('MMM')
            .format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
      }
      return m.month.substring(5); // Fallback
    }).toList();

    // Compute spots for chart
    final actualSpots = actual
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.total))
        .toList();

    // Handle moving average - convert to use same x-axis scale
    final maSpots = <FlSpot>[];
    if (movingAverage.isNotEmpty) {
      // Get date range from actuals
      final startDate = _parseYearMonth(actual.first.month);
      final endDate = _parseYearMonth(actual.last.month);

      // Map moving average points to month indices
      for (var point in movingAverage) {
        // Find which month this point belongs to
        for (int i = 0; i < actual.length; i++) {
          final monthDate = _parseYearMonth(actual[i].month);
          if (_isSameMonth(point.date, monthDate)) {
            maSpots.add(FlSpot(i.toDouble(), point.total));
            break;
          }
        }
      }
    }

    // Forecast spots - these come after actual data points
    final forecastSpots = forecast
        .asMap()
        .entries
        .map((e) => FlSpot(actual.length - 1 + e.key + 1, e.value.predicted))
        .toList();

    // Calculate max Y value for chart scaling
    final allValues = [
      ...actual.map((e) => e.total),
      if (maSpots.isNotEmpty) ...maSpots.map((e) => e.y),
      if (forecastSpots.isNotEmpty) ...forecastSpots.map((e) => e.y),
    ];

    final maxY = allValues.isNotEmpty
        ? allValues.reduce((a, b) => a > b ? a : b) * 1.2
        : 1000;

    // Create extended month labels including forecast months
    final allMonthLabels = [
      ...displayMonths,
      ...forecast.map((f) {
        final parts = f.period.split('-');
        return DateFormat('MMM')
            .format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
      })
    ];

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Monthly Expense Trend",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Legend
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem("Actual", gold),
              const SizedBox(width: 16),
              if (maSpots.isNotEmpty) _buildLegendItem("Moving Avg", orange),
              if (forecastSpots.isNotEmpty) ...[
                const SizedBox(width: 16),
                _buildLegendItem("Forecast", pink),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 8),
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot touchedSpot) {
                        handleBuiltInTouches:
                        true;
                        // Assuming 'bgColor' is a Color variable you have defined elsewhere
                        return bgColor.withOpacity(0.8);
                      },
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final spotIndex = spot.spotIndex;
                          String label = '';

                          // Determine which dataset this belongs to
                          if (spot.barIndex == 0) {
                            // Actual
                            label = "Actual: ";
                          } else if (spot.barIndex == 1) {
                            // Moving avg
                            label = "Avg: ";
                          } else {
                            // Forecast
                            label = "Forecast: ";
                          }

                          // Add month info if available
                          if (spotIndex < allMonthLabels.length) {
                            label += "${allMonthLabels[spotIndex]}: ";
                          }

                          return LineTooltipItem(
                            "$label₹${spot.y.toStringAsFixed(0)}",
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateYInterval(maxY.toDouble()),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white12,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval:
                            _calculateXLabelInterval(allMonthLabels.length),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= allMonthLabels.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              allMonthLabels[index],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: _calculateYInterval(maxY.toDouble()),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrency(value),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (allMonthLabels.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY.toDouble(),
                  lineBarsData: [
                    // Actual data series
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: false, // Line is straight, not curved
                      color: gold,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: gold,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: gold.withOpacity(0.2),
                      ),
                    ),

                    // Moving average series (if available)
                    if (maSpots.isNotEmpty)
                      LineChartBarData(
                        spots: maSpots,
                        isCurved: true,
                        color: orange,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
                      ),

                    // Forecast series (if available)
                    if (forecastSpots.isNotEmpty)
                      LineChartBarData(
                        spots: forecastSpots,
                        isCurved: true,
                        color: pink,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: pink,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        dashArray: [2, 4],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build legend items
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Parse year-month string into DateTime
  DateTime _parseYearMonth(String yearMonth) {
    final parts = yearMonth.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  // Check if two dates are in the same month
  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  // Calculate Y-axis interval based on max value
  double _calculateYInterval(double maxY) {
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    if (maxY <= 50000) return 10000;
    if (maxY <= 100000) return 20000;
    return maxY / 5;
  }

  // Calculate X-axis label interval to prevent crowding
  double _calculateXLabelInterval(int count) {
    if (count <= 6) return 1;
    if (count <= 12) return 2;
    return count / 6; // Show approximately 6 labels
  }

  // Format currency values for readability
  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    } else if (value == value.toInt()) {
      return '₹${value.toInt()}';
    } else {
      return '₹${value.toStringAsFixed(1)}';
    }
  }
}
