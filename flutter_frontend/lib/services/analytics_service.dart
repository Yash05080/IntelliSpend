import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ——— Models —————————————————————————————————————————————————

/// 1) Total spent on each weekday (Mon…Sun)
class WeekdayExpense {
  final String weekday; // “Mon”, “Tue”, …
  final double total;
  WeekdayExpense({required this.weekday, required this.total});
}

/// 2) Average transaction amount per category
class CategoryAverage {
  final String category;
  final double average;
  CategoryAverage({required this.category, required this.average});
}

/// 3) Total spent per month (for trend over last 12 months)
class MonthlyExpense {
  final String month; // “2025-01”, “2025-02”, …
  final double total;
  MonthlyExpense({required this.month, required this.total});
}

/// 4) For moving average series
class ExpenseDayData {
  final DateTime date;
  final double total;
  ExpenseDayData({required this.date, required this.total});
}

/// 5) A single high-value transaction anomaly
class Anomaly {
  final String id;
  final double amount;
  final DateTime date;
  Anomaly({required this.id, required this.amount, required this.date});
}

/// —— New models ——————————————————————————————————————————————
/// 7) Count of transactions per category
class CategoryCount {
  final String category;
  final int count;
  CategoryCount({required this.category, required this.count});
}

/// 8) Median & variance per category
class CategoryStats {
  final String category;
  final double median;
  final double variance;
  CategoryStats({
    required this.category,
    required this.median,
    required this.variance,
  });
}

/// 9) Forecast point for next months
class ForecastPoint {
  final String period; // “2025-05”, etc.
  final double predicted;
  ForecastPoint({required this.period, required this.predicted});
}

/// ——— Service —————————————————————————————————————————————————

class AnalyticsService {
  final _db = Supabase.instance.client;
  Future<List<WeekdayExpense>> getSpendingByWeekdayFiltered({
  required String userId,
  required DateTime startDate,
  required DateTime endDate,
  List<String>? categories,
}) async {
  final query = _db
      .from('transactions')
      .select('date, amount')
      .eq('user_id', userId)
      .gte('date', startDate.toIso8601String())
      .lte('date', endDate.toIso8601String());

  if (categories != null && categories.isNotEmpty) {
    query.inFilter('category', categories);
  }

  final res = await query;
  final raw = List<Map>.from(res);
  final Map<int, double> sums = {};
  for (var tx in raw) {
    final dt = DateTime.parse(tx['date']);
    sums[dt.weekday] = (sums[dt.weekday] ?? 0) + (tx['amount'] as num).toDouble();
  }

  const names = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
  return sums.entries
      .map((e) => WeekdayExpense(weekday: names[e.key]!, total: e.value))
      .toList()
    ..sort((a, b) => names.keys.firstWhere((k) => names[k] == a.weekday)
        .compareTo(names.keys.firstWhere((k) => names[k] == b.weekday)));
}
Future<List<CategoryAverage>> getAverageSpendPerCategoryFiltered({
  required String userId,
  required DateTime startDate,
  required DateTime endDate,
  List<String>? categories,
}) async {
  final query = _db
      .from('transactions')
      .select('category, amount')
      .eq('user_id', userId)
      .gte('date', startDate.toIso8601String())
      .lte('date', endDate.toIso8601String());

  if (categories != null && categories.isNotEmpty) {
    query.inFilter('category', categories);
  }

  final res = await query;
  final raw = List<Map>.from(res);
  final Map<String, List<double>> buckets = {};
  for (var tx in raw) {
    final cat = tx['category'];
    final amt = (tx['amount'] as num).toDouble();
    buckets.putIfAbsent(cat, () => []).add(amt);
  }

  return buckets.entries
      .map((e) => CategoryAverage(
            category: e.key,
            average: e.value.reduce((a, b) => a + b) / e.value.length,
          ))
      .toList()
    ..sort((a, b) => b.average.compareTo(a.average));
}


  /// 1) Total spending by weekday (Mon…Sun)
  Future<List<WeekdayExpense>> getSpendingByWeekday(String userId) async {
    final res = await _db
        .from('transactions')
        .select('date, amount')
        .eq('user_id', userId);
    final raw = List<Map>.from(res);
    final Map<int, double> sums = {};
    for (var tx in raw) {
      final dt = DateTime.parse(tx['date'] as String);
      sums[dt.weekday] =
          (sums[dt.weekday] ?? 0) + (tx['amount'] as num).toDouble();
    }
    const names = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun'
    };
    return sums.entries
        .map((e) => WeekdayExpense(weekday: names[e.key]!, total: e.value))
        .toList()
      ..sort((a, b) {
        final ai = names.entries.firstWhere((e) => e.value == a.weekday).key;
        final bi = names.entries.firstWhere((e) => e.value == b.weekday).key;
        return ai.compareTo(bi);
      });
  }

  /// 2) Average transaction amount per category
  Future<List<CategoryAverage>> getAverageSpendPerCategory(
      String userId) async {
    final res = await _db
        .from('transactions')
        .select('category, amount')
        .eq('user_id', userId);
    final raw = List<Map>.from(res);
    final Map<String, List<double>> buckets = {};
    for (var tx in raw) {
      final cat = tx['category'] as String;
      final amt = (tx['amount'] as num).toDouble();
      buckets.putIfAbsent(cat, () => []).add(amt);
    }
    return buckets.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return CategoryAverage(category: e.key, average: avg);
    }).toList()
      ..sort((a, b) => b.average.compareTo(a.average));
  }

  /// 3) Monthly spending trend (last 12 months)
  Future<List<MonthlyExpense>> getMonthlyExpenseTrend(String userId) async {
    final res = await _db
        .from('transactions')
        .select('date, amount')
        .eq('user_id', userId);
    final raw = List<Map>.from(res);
    final Map<String, double> sums = {};
    for (var tx in raw) {
      final dt = DateTime.parse(tx['date'] as String);
      final key =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
      sums[key] = (sums[key] ?? 0) + (tx['amount'] as num).toDouble();
    }
    final months = sums.entries
        .map((e) => MonthlyExpense(month: e.key, total: e.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    // last 12 only
    return months.skip((months.length - 12).clamp(0, months.length)).toList();
  }

  /// 4) 7-day moving average (rolling) over last 30 days
  Future<List<ExpenseDayData>> getMovingAverage(String userId,
      {int windowDays = 7}) async {
    final raw = await Supabase.instance.client
    .rpc('get_last_7_days_expenses', params: {'user_id': userId});

    final days = (raw as List)
        .map((e) => ExpenseDayData(
              date: DateTime.parse(e['date']),
              total: (e['total'] as num).toDouble(),
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final List<ExpenseDayData> ma = [];
    for (int i = 0; i < days.length; i++) {
      final slice = days.sublist(max(0, i - windowDays + 1), i + 1);
      final avg =
          slice.map((d) => d.total).reduce((a, b) => a + b) / slice.length;
      ma.add(ExpenseDayData(date: days[i].date, total: avg));
    }
    return ma;
  }

  /// 5) Detect anomalies: days > mean + 2σ
  Future<List<Anomaly>> detectSpendingAnomalies(String userId) async {
    final txs = await _db
        .from('transactions')
        .select('id, date, amount')
        .eq('user_id', userId);
    final data = List<Map>.from(txs);
    final Map<String, double> daily = {};
    for (var tx in data) {
      final day = DateTime.parse(tx['date']).toIso8601String().substring(0, 10);
      daily[day] = (daily[day] ?? 0) + (tx['amount'] as num).toDouble();
    }
    final vals = daily.values.toList();
    final mean = vals.reduce((a, b) => a + b) / vals.length;
    final sigma = sqrt(
        vals.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
            vals.length);
    final outlierDays = daily.entries
        .where((e) => e.value > mean + 2 * sigma)
        .map((e) => e.key)
        .toSet();
    return data
        .where((tx) {
          final day =
              DateTime.parse(tx['date']).toIso8601String().substring(0, 10);
          return outlierDays.contains(day);
        })
        .map((tx) => Anomaly(
              id: tx['id'].toString(),
              amount: (tx['amount'] as num).toDouble(),
              date: DateTime.parse(tx['date']),
            ))
        .toList();
  }

  /// 6) Top N categories by average spend
  Future<List<CategoryAverage>> topCategories(String userId,
      {int n = 5}) async {
    final all = await getAverageSpendPerCategory(userId);
    return all.take(n).toList();
  }

  /// 7) Count of transactions per category
  Future<List<CategoryCount>> getTransactionCountPerCategory(
      String userId) async {
    final res =
        await _db.from('transactions').select('category').eq('user_id', userId);
    final raw = List<Map>.from(res);
    final Map<String, int> counts = {};
    for (var tx in raw) {
      final cat = tx['category'] as String;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => CategoryCount(category: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  /// 8) Median & variance per category
  Future<List<CategoryStats>> getCategoryMedianVariance(String userId) async {
    final res = await _db
        .from('transactions')
        .select('category, amount')
        .eq('user_id', userId);
    final raw = List<Map>.from(res);
    final Map<String, List<double>> buckets = {};
    for (var tx in raw) {
      final cat = tx['category'] as String;
      final amt = (tx['amount'] as num).toDouble();
      buckets.putIfAbsent(cat, () => []).add(amt);
    }
    final stats = <CategoryStats>[];
    buckets.forEach((cat, list) {
      list.sort();
      // median
      double median;
      final mid = list.length ~/ 2;
      if (list.length.isOdd) {
        median = list[mid];
      } else {
        median = (list[mid - 1] + list[mid]) / 2;
      }
      // variance
      final mean = list.reduce((a, b) => a + b) / list.length;
      final variance =
          list.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
              list.length;
      stats.add(CategoryStats(
          category: cat, median: median, variance: variance.toDouble()));
    });
    return stats..sort((a, b) => b.median.compareTo(a.median));
  }

  /// 9) Simple linear regression forecast for nextMonths
  Future<List<ForecastPoint>> forecastMonthlyExpenses(String userId,
      {int nextMonths = 1}) async {
    final actuals = await getMonthlyExpenseTrend(userId);
    if (actuals.length < 2) return [];
    // prepare x/y
    final xs = List<double>.generate(actuals.length, (i) => i.toDouble());
    final ys = actuals.map((m) => m.total).toList();
    final n = xs.length;
    final sumX = xs.reduce((a, b) => a + b);
    final sumY = ys.reduce((a, b) => a + b);
    final sumXY =
        List.generate(n, (i) => xs[i] * ys[i]).reduce((a, b) => a + b);
    final sumX2 = xs.map((x) => x * x).reduce((a, b) => a + b);
    final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final b = (sumY - m * sumX) / n;

    // parse last year/month
    final parts = actuals.last.month.split('-');
    final lastYear = int.parse(parts[0]);
    final lastMonth = int.parse(parts[1]);

    final forecasts = <ForecastPoint>[];
    for (int k = 1; k <= nextMonths; k++) {
      final xPred = xs.last + k;
      final yPred = m * xPred + b;
      final dt = DateTime(lastYear, lastMonth + k);
      final label =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
      forecasts.add(ForecastPoint(period: label, predicted: yPred));
    }
    return forecasts;
  }
}

