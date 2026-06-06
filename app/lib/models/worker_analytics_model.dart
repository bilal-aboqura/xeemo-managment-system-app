/// Worker analytics data types and models
/// Note: WorkerAnalyticsData uses freezed but needs build_runner to generate files
library;

/// Aggregated analytics summary for a worker
class WorkerAnalyticsSummary {
  final String workerId;
  final String workerName;
  final AnalyticsDateRange dateRange;
  final int totalTickets;
  final double totalSales;
  final double averageProductivityScore;
  final double averageActivityHours;
  final List<DailyAnalytics> dailyAnalytics;
  final Map<String, int> productBreakdown;
  final TrendData? trend;

  WorkerAnalyticsSummary({
    required this.workerId,
    required this.workerName,
    required this.dateRange,
    required this.totalTickets,
    required this.totalSales,
    required this.averageProductivityScore,
    required this.averageActivityHours,
    required this.dailyAnalytics,
    required this.productBreakdown,
    this.trend,
  });
}

/// Daily analytics data point for charts
class DailyAnalytics {
  final DateTime date;
  final int ticketCount;
  final double salesAmount;
  final double productivityScore;
  final List<TicketInfo> tickets;

  DailyAnalytics({
    required this.date,
    required this.ticketCount,
    required this.salesAmount,
    required this.productivityScore,
    this.tickets = const [],
  });

  double get totalSales => salesAmount;
}

/// Ticket info for display in daily analytics
class TicketInfo {
  final String id;
  final String laundryName;
  final String area;
  final double saleAmount;
  final DateTime createdAt;
  final List<ProductInfo> products;

  TicketInfo({
    required this.id,
    required this.laundryName,
    required this.area,
    required this.saleAmount,
    required this.createdAt,
    this.products = const [],
  });
}

/// Product info for ticket display
class ProductInfo {
  final String name;
  final int quantity;

  ProductInfo({required this.name, required this.quantity});
}

/// Trend data for analytics
class TrendData {
  final double salesTrend; // Percentage change
  final double ticketsTrend;
  final double productivityTrend;
  final bool isImproving;

  TrendData({
    required this.salesTrend,
    required this.ticketsTrend,
    required this.productivityTrend,
  }) : isImproving = (salesTrend + ticketsTrend + productivityTrend) / 3 > 0;
}

/// Date range for filtering (named to avoid conflict with Flutter's DateTimeRange)
class AnalyticsDateRange {
  final DateTime start;
  final DateTime end;

  AnalyticsDateRange({required this.start, required this.end});

  /// Check if a date is within this range
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  /// Get number of days in range
  int get days => end.difference(start).inDays + 1;
}

/// Preset date range options
enum DateRangePreset {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last7Days,
  last30Days,
  last90Days,
  custom,
}

/// Extension for date range preset labels
extension DateRangePresetExtension on DateRangePreset {
  String get arabicLabel {
    switch (this) {
      case DateRangePreset.today:
        return 'اليوم';
      case DateRangePreset.yesterday:
        return 'أمس';
      case DateRangePreset.thisWeek:
        return 'هذا الأسبوع';
      case DateRangePreset.lastWeek:
        return 'الأسبوع الماضي';
      case DateRangePreset.thisMonth:
        return 'هذا الشهر';
      case DateRangePreset.lastMonth:
        return 'الشهر الماضي';
      case DateRangePreset.last7Days:
        return 'آخر 7 أيام';
      case DateRangePreset.last30Days:
        return 'آخر 30 يوم';
      case DateRangePreset.last90Days:
        return 'آخر 90 يوم';
      case DateRangePreset.custom:
        return 'نطاق مخصص';
    }
  }

  /// Get the date range for this preset
  AnalyticsDateRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateRangePreset.today:
        return AnalyticsDateRange(start: today, end: today);

      case DateRangePreset.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return AnalyticsDateRange(start: yesterday, end: yesterday);

      case DateRangePreset.thisWeek:
        // Start from Sunday
        final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
        return AnalyticsDateRange(start: startOfWeek, end: today);

      case DateRangePreset.lastWeek:
        final startOfThisWeek = today.subtract(
          Duration(days: today.weekday % 7),
        );
        final startOfLastWeek = startOfThisWeek.subtract(
          const Duration(days: 7),
        );
        final endOfLastWeek = startOfThisWeek.subtract(const Duration(days: 1));
        return AnalyticsDateRange(start: startOfLastWeek, end: endOfLastWeek);

      case DateRangePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return AnalyticsDateRange(start: startOfMonth, end: today);

      case DateRangePreset.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0);
        return AnalyticsDateRange(start: startOfLastMonth, end: endOfLastMonth);

      case DateRangePreset.last7Days:
        return AnalyticsDateRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );

      case DateRangePreset.last30Days:
        return AnalyticsDateRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );

      case DateRangePreset.last90Days:
        return AnalyticsDateRange(
          start: today.subtract(const Duration(days: 89)),
          end: today,
        );

      case DateRangePreset.custom:
        // Default to last 30 days for custom (will be overridden)
        return AnalyticsDateRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
    }
  }
}
