import '../models/worker_analytics_model.dart';
import '../models/sales_ticket_model.dart';
import '../config/app_config.dart';
import '../core/error_handler.dart';
import 'supabase_service.dart';

/// Service for fetching and computing worker analytics
class AnalyticsService {
  /// Fetch analytics for a specific worker within a date range
  Future<WorkerAnalyticsSummary?> getWorkerAnalytics({
    required String workerId,
    required String workerName,
    required AnalyticsDateRange dateRange,
  }) async {
    if (!AppConfig.isSupabaseConfigured) {
      AppErrorHandler.logWarning('Supabase not configured for analytics');
      return null;
    }

    try {
      AppErrorHandler.logInfo(
        'Fetching analytics for $workerId: ${dateRange.start} - ${dateRange.end}',
      );

      // Fetch tickets for the worker within date range
      final ticketsResponse = await SupabaseService.client
          .from('tickets')
          .select()
          .eq('worker_id', workerId)
          .gte('created_at', dateRange.start.toIso8601String())
          .lte(
            'created_at',
            dateRange.end.add(const Duration(days: 1)).toIso8601String(),
          )
          .order('created_at', ascending: true);

      final tickets = (ticketsResponse as List)
          .map((json) => SalesTicket.fromJson(json as Map<String, dynamic>))
          .toList();

      if (tickets.isEmpty) {
        return WorkerAnalyticsSummary(
          workerId: workerId,
          workerName: workerName,
          dateRange: dateRange,
          totalTickets: 0,
          totalSales: 0,
          averageProductivityScore: 0,
          averageActivityHours: 0,
          dailyAnalytics: [],
          productBreakdown: {},
        );
      }

      // Calculate aggregated analytics
      return _computeAnalytics(
        tickets: tickets,
        workerId: workerId,
        workerName: workerName,
        dateRange: dateRange,
      );
    } catch (e, stackTrace) {
      AppErrorHandler.logError(
        'Failed to fetch worker analytics',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Fetch analytics for all workers within a date range
  Future<List<WorkerAnalyticsSummary>> getAllWorkersAnalytics({
    required AnalyticsDateRange dateRange,
  }) async {
    if (!AppConfig.isSupabaseConfigured) {
      return [];
    }

    try {
      // Fetch all tickets within date range
      final ticketsResponse = await SupabaseService.client
          .from('tickets')
          .select()
          .gte('created_at', dateRange.start.toIso8601String())
          .lte(
            'created_at',
            dateRange.end.add(const Duration(days: 1)).toIso8601String(),
          )
          .order('created_at', ascending: true);

      final tickets = (ticketsResponse as List)
          .map((json) => SalesTicket.fromJson(json as Map<String, dynamic>))
          .toList();

      // Group by worker
      final Map<String, List<SalesTicket>> ticketsByWorker = {};
      final Map<String, String> workerNames = {};

      for (final ticket in tickets) {
        ticketsByWorker.putIfAbsent(ticket.workerId, () => []).add(ticket);
        if (workerNames[ticket.workerId] == null &&
            ticket.workerName.isNotEmpty) {
          workerNames[ticket.workerId] = ticket.workerName;
        }
      }

      // Compute analytics for each worker
      final List<WorkerAnalyticsSummary> summaries = [];
      for (final entry in ticketsByWorker.entries) {
        final summary = _computeAnalytics(
          tickets: entry.value,
          workerId: entry.key,
          workerName: workerNames[entry.key] ?? 'عامل غير معروف',
          dateRange: dateRange,
        );
        summaries.add(summary);
      }

      // Sort by total sales descending
      summaries.sort((a, b) => b.totalSales.compareTo(a.totalSales));

      return summaries;
    } catch (e, stackTrace) {
      AppErrorHandler.logError(
        'Failed to fetch all workers analytics',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Compute analytics from tickets
  WorkerAnalyticsSummary _computeAnalytics({
    required List<SalesTicket> tickets,
    required String workerId,
    required String workerName,
    required AnalyticsDateRange dateRange,
  }) {
    // Calculate totals
    final totalTickets = tickets.length;
    final totalSales = tickets.fold<double>(0, (sum, t) => sum + t.saleAmount);

    // Group by date for daily analytics
    final Map<DateTime, List<SalesTicket>> ticketsByDate = {};
    for (final ticket in tickets) {
      final date = DateTime(
        ticket.createdAt.year,
        ticket.createdAt.month,
        ticket.createdAt.day,
      );
      ticketsByDate.putIfAbsent(date, () => []).add(ticket);
    }

    // Build daily analytics
    final List<DailyAnalytics> dailyAnalytics = [];
    for (final entry in ticketsByDate.entries) {
      final dayTickets = entry.value;
      final daySales = dayTickets.fold<double>(
        0,
        (sum, t) => sum + t.saleAmount,
      );

      // Convert SalesTicket to TicketInfo
      final ticketInfos = dayTickets
          .map(
            (t) => TicketInfo(
              id: t.ticketId,
              laundryName: t.laundryName.isNotEmpty
                  ? t.laundryName
                  : t.clientName,
              area: t.clientName, // Use client name as area for now
              saleAmount: t.saleAmount,
              createdAt: t.createdAt,
              products: t.products
                  .map(
                    (p) => ProductInfo(
                      name: p
                          .productId, // Will be resolved to name later if needed
                      quantity: p.quantity,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      dailyAnalytics.add(
        DailyAnalytics(
          date: entry.key,
          ticketCount: dayTickets.length,
          salesAmount: daySales,
          productivityScore: _calculateProductivityScore(dayTickets),
          tickets: ticketInfos,
        ),
      );
    }

    // Sort by date
    dailyAnalytics.sort((a, b) => a.date.compareTo(b.date));

    // Calculate product breakdown
    final Map<String, int> productBreakdown = {};
    for (final ticket in tickets) {
      for (final product in ticket.products) {
        productBreakdown[product.productId] =
            (productBreakdown[product.productId] ?? 0) + product.quantity;
      }
    }

    // Calculate averages
    final avgProductivity = dailyAnalytics.isEmpty
        ? 0.0
        : dailyAnalytics.fold<double>(
                0,
                (sum, d) => sum + d.productivityScore,
              ) /
              dailyAnalytics.length;

    // Estimate activity hours (based on ticket creation times)
    final avgActivityHours = _estimateAverageActivityHours(
      tickets,
      dateRange.days,
    );

    // Calculate trend if enough data
    TrendData? trend;
    if (dailyAnalytics.length >= 3) {
      trend = _calculateTrend(dailyAnalytics);
    }

    return WorkerAnalyticsSummary(
      workerId: workerId,
      workerName: workerName,
      dateRange: dateRange,
      totalTickets: totalTickets,
      totalSales: totalSales,
      averageProductivityScore: avgProductivity,
      averageActivityHours: avgActivityHours,
      dailyAnalytics: dailyAnalytics,
      productBreakdown: productBreakdown,
      trend: trend,
    );
  }

  /// Calculate a productivity score based on tickets
  double _calculateProductivityScore(List<SalesTicket> tickets) {
    if (tickets.isEmpty) return 0;

    // Factors: ticket count, average sale amount, variety of products
    final ticketCount = tickets.length;
    final avgSaleAmount =
        tickets.fold<double>(0, (sum, t) => sum + t.saleAmount) / ticketCount;

    // Collect unique products
    final Set<String> uniqueProducts = {};
    for (final ticket in tickets) {
      for (final product in ticket.products) {
        uniqueProducts.add(product.productId);
      }
    }

    // Simple scoring formula (can be refined)
    double score = 0;
    score += (ticketCount * 10)
        .clamp(0, 30)
        .toDouble(); // Up to 30 points for tickets
    score += (avgSaleAmount / 100).clamp(
      0,
      40,
    ); // Up to 40 points for average sale
    score += (uniqueProducts.length * 5)
        .clamp(0, 30)
        .toDouble(); // Up to 30 points for product variety

    return score.clamp(0, 100);
  }

  /// Estimate average daily activity hours from tickets
  double _estimateAverageActivityHours(List<SalesTicket> tickets, int days) {
    if (tickets.isEmpty || days <= 0) return 0;

    // Group by date
    final Map<DateTime, List<DateTime>> ticketTimesByDate = {};
    for (final ticket in tickets) {
      final date = DateTime(
        ticket.createdAt.year,
        ticket.createdAt.month,
        ticket.createdAt.day,
      );
      ticketTimesByDate.putIfAbsent(date, () => []).add(ticket.createdAt);
    }

    // Calculate activity span for each day
    double totalHours = 0;
    for (final times in ticketTimesByDate.values) {
      if (times.length > 1) {
        times.sort();
        final span = times.last.difference(times.first);
        totalHours += span.inMinutes / 60;
      } else {
        totalHours += 1; // Minimum 1 hour if only one ticket
      }
    }

    return totalHours / ticketTimesByDate.length;
  }

  /// Calculate trend from daily analytics
  TrendData _calculateTrend(List<DailyAnalytics> dailyAnalytics) {
    if (dailyAnalytics.length < 2) {
      return TrendData(salesTrend: 0, ticketsTrend: 0, productivityTrend: 0);
    }

    // Split into halves for comparison
    final midpoint = dailyAnalytics.length ~/ 2;
    final firstHalf = dailyAnalytics.take(midpoint).toList();
    final secondHalf = dailyAnalytics.skip(midpoint).toList();

    // Calculate averages
    double avgSalesFirst =
        firstHalf.fold<double>(0, (s, d) => s + d.salesAmount) /
        firstHalf.length;
    double avgSalesSecond =
        secondHalf.fold<double>(0, (s, d) => s + d.salesAmount) /
        secondHalf.length;

    double avgTicketsFirst =
        firstHalf.fold<int>(0, (s, d) => s + d.ticketCount) / firstHalf.length;
    double avgTicketsSecond =
        secondHalf.fold<int>(0, (s, d) => s + d.ticketCount) /
        secondHalf.length;

    double avgProdFirst =
        firstHalf.fold<double>(0, (s, d) => s + d.productivityScore) /
        firstHalf.length;
    double avgProdSecond =
        secondHalf.fold<double>(0, (s, d) => s + d.productivityScore) /
        secondHalf.length;

    // Calculate percentage changes
    double salesTrend = avgSalesFirst > 0
        ? ((avgSalesSecond - avgSalesFirst) / avgSalesFirst) * 100
        : 0;
    double ticketsTrend = avgTicketsFirst > 0
        ? ((avgTicketsSecond - avgTicketsFirst) / avgTicketsFirst) * 100
        : 0;
    double productivityTrend = avgProdFirst > 0
        ? ((avgProdSecond - avgProdFirst) / avgProdFirst) * 100
        : 0;

    return TrendData(
      salesTrend: salesTrend,
      ticketsTrend: ticketsTrend,
      productivityTrend: productivityTrend,
    );
  }
}
