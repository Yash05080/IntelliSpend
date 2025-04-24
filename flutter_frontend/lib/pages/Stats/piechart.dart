import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> categoryData;

  const PieChartWidget({super.key, required this.categoryData});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? touchedIndex;

  final List<Color> pieColors = [
    Color(0xFFF2C341), // primary - golden yellow
    Color(0xFFF1A410), // secondary - orange
    Color(0xFFF3696E), // tertiary - coral pink
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.tealAccent,
    Colors.purpleAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final total = widget.categoryData.values.fold(0.0, (sum, val) => sum + val);
    final theme = Theme.of(context).colorScheme;

    final List<PieChartSectionData> sections = [];
    int index = 0;

    widget.categoryData.forEach((category, amount) {
      final isTouched = index == touchedIndex;
      final double radius = isTouched ? 85 : 70;
      final percentage = ((amount / total) * 100).toStringAsFixed(1);

      sections.add(PieChartSectionData(
        color: pieColors[index % pieColors.length],
        value: amount,
        radius: radius,
        title: '$percentage%',
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        badgeWidget: isTouched
            ? Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        badgePositionPercentageOffset: .95,
      ));

      index++;
    });

    return Column(
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF232842), // softer navy background
            borderRadius: BorderRadius.circular(16),
          ),
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 3,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    touchedIndex =
                        response?.touchedSection?.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        /// 🔖 Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children:
              widget.categoryData.keys.toList().asMap().entries.map((entry) {
            final idx = entry.key;
            final cat = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: pieColors[idx % pieColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  cat,
                  style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
