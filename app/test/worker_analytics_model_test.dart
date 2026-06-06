import 'package:flutter_test/flutter_test.dart';
import 'package:xeemo_sales/models/worker_analytics_model.dart';

void main() {
  group('AnalyticsDateRange', () {
    test('should calculate days correctly', () {
      final range = AnalyticsDateRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 7),
      );

      expect(range.days, 7);
    });

    test('should calculate single day range', () {
      final range = AnalyticsDateRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 1),
      );

      expect(range.days, 1);
    });

    test('should correctly check if date is within range', () {
      final range = AnalyticsDateRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );

      expect(range.contains(DateTime(2024, 1, 15)), true);
      expect(range.contains(DateTime(2024, 1, 1)), true);
      expect(range.contains(DateTime(2024, 1, 31)), true);
      expect(range.contains(DateTime(2024, 2, 1)), false);
      expect(range.contains(DateTime(2023, 12, 31)), false);
    });
  });

  group('DateRangePreset', () {
    test('should have correct Arabic labels', () {
      expect(DateRangePreset.today.arabicLabel, 'اليوم');
      expect(DateRangePreset.yesterday.arabicLabel, 'أمس');
      expect(DateRangePreset.thisWeek.arabicLabel, 'هذا الأسبوع');
      expect(DateRangePreset.lastWeek.arabicLabel, 'الأسبوع الماضي');
      expect(DateRangePreset.thisMonth.arabicLabel, 'هذا الشهر');
      expect(DateRangePreset.lastMonth.arabicLabel, 'الشهر الماضي');
      expect(DateRangePreset.last7Days.arabicLabel, 'آخر 7 أيام');
      expect(DateRangePreset.last30Days.arabicLabel, 'آخر 30 يوم');
      expect(DateRangePreset.last90Days.arabicLabel, 'آخر 90 يوم');
      expect(DateRangePreset.custom.arabicLabel, 'نطاق مخصص');
    });

    test('today preset should return single day range', () {
      final range = DateRangePreset.today.getDateRange();
      expect(range.days, 1);
    });

    test('yesterday preset should return single day range', () {
      final range = DateRangePreset.yesterday.getDateRange();
      expect(range.days, 1);
    });

    test('last7Days preset should return 7 days', () {
      final range = DateRangePreset.last7Days.getDateRange();
      expect(range.days, 7);
    });

    test('last30Days preset should return 30 days', () {
      final range = DateRangePreset.last30Days.getDateRange();
      expect(range.days, 30);
    });

    test('last90Days preset should return 90 days', () {
      final range = DateRangePreset.last90Days.getDateRange();
      expect(range.days, 90);
    });
  });

  group('WorkerAnalyticsSummary', () {
    test('should calculate correct values', () {
      final summary = WorkerAnalyticsSummary(
        workerId: 'worker-1',
        workerName: 'Test Worker',
        dateRange: AnalyticsDateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        totalTickets: 50,
        totalSales: 5000.0,
        averageProductivityScore: 75.0,
        averageActivityHours: 6.5,
        dailyAnalytics: [],
        productBreakdown: {'product-1': 30, 'product-2': 20},
      );

      expect(summary.workerId, 'worker-1');
      expect(summary.workerName, 'Test Worker');
      expect(summary.totalTickets, 50);
      expect(summary.totalSales, 5000.0);
      expect(summary.averageProductivityScore, 75.0);
      expect(summary.averageActivityHours, 6.5);
      expect(summary.productBreakdown.length, 2);
    });
  });

  group('DailyAnalytics', () {
    test('should store date and metrics correctly', () {
      final daily = DailyAnalytics(
        date: DateTime(2024, 1, 15),
        ticketCount: 10,
        salesAmount: 500.0,
        productivityScore: 80.0,
      );

      expect(daily.date, DateTime(2024, 1, 15));
      expect(daily.ticketCount, 10);
      expect(daily.salesAmount, 500.0);
      expect(daily.productivityScore, 80.0);
    });
  });

  group('TrendData', () {
    test('should mark as improving when average trend is positive', () {
      final trend = TrendData(
        salesTrend: 10.0,
        ticketsTrend: 5.0,
        productivityTrend: 15.0,
      );

      expect(trend.isImproving, true);
    });

    test('should mark as not improving when average trend is negative', () {
      final trend = TrendData(
        salesTrend: -10.0,
        ticketsTrend: -5.0,
        productivityTrend: -15.0,
      );

      expect(trend.isImproving, false);
    });

    test('should handle mixed trends', () {
      final trend = TrendData(
        salesTrend: 10.0,
        ticketsTrend: -5.0,
        productivityTrend: 5.0,
      );

      // Average: (10 - 5 + 5) / 3 = 3.33 > 0, so improving
      expect(trend.isImproving, true);
    });

    test('should handle zero trends', () {
      final trend = TrendData(
        salesTrend: 0.0,
        ticketsTrend: 0.0,
        productivityTrend: 0.0,
      );

      expect(trend.isImproving, false);
    });
  });
}
