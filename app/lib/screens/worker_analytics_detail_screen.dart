import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/worker_analytics_model.dart';
import '../services/analytics_service.dart';
import '../services/user_service.dart';
import '../providers/product_provider.dart';
import '../core/theme.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(),
);

/// Provider for selected date range preset
final selectedDateRangePresetProvider = StateProvider<DateRangePreset>((ref) {
  return DateRangePreset.last30Days;
});

/// Provider for custom date range
final customDateRangeProvider = StateProvider<AnalyticsDateRange?>(
  (ref) => null,
);

/// Provider for worker analytics with date range
final workerAnalyticsDetailProvider =
    FutureProvider.family<
      WorkerAnalyticsSummary?,
      ({String workerId, String workerName})
    >((ref, args) async {
      final analyticsService = ref.watch(analyticsServiceProvider);
      final preset = ref.watch(selectedDateRangePresetProvider);
      final customRange = ref.watch(customDateRangeProvider);

      final AnalyticsDateRange dateRange;
      if (preset == DateRangePreset.custom && customRange != null) {
        dateRange = customRange;
      } else {
        dateRange = preset.getDateRange();
      }

      return analyticsService.getWorkerAnalytics(
        workerId: args.workerId,
        workerName: args.workerName,
        dateRange: dateRange,
      );
    });

/// Screen for detailed worker analytics with charts
class WorkerAnalyticsDetailScreen extends ConsumerStatefulWidget {
  final String workerId;
  final String workerName;

  const WorkerAnalyticsDetailScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  @override
  ConsumerState<WorkerAnalyticsDetailScreen> createState() =>
      _WorkerAnalyticsDetailScreenState();
}

class _WorkerAnalyticsDetailScreenState
    extends ConsumerState<WorkerAnalyticsDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(
      workerAnalyticsDetailProvider((
        workerId: widget.workerId,
        workerName: widget.workerName,
      )),
    );
    final selectedPreset = ref.watch(selectedDateRangePresetProvider);
    final products = ref.watch(productListProvider);
    final productNames = {for (var p in products) p.productId: p.name};

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryRed,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () async {
                    final userService = ref.read(userServiceProvider);
                    // Use widget.workerId
                    final user = await userService.getUserById(widget.workerId);
                    if (user != null && context.mounted) {
                      context.push('/edit-user', extra: user);
                    }
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB91C1C), Color(0xFF6E0A0A)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  widget.workerName.isNotEmpty
                                      ? widget.workerName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 24,
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
                                    widget.workerName,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'تحليلات الأداء',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Date range filter
          SliverToBoxAdapter(child: _buildDateRangeFilter(selectedPreset)),

          // Content
          SliverToBoxAdapter(
            child: analyticsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(24),
                child: _buildErrorState(error.toString()),
              ),
              data: (analytics) {
                if (analytics == null) {
                  return _buildEmptyState();
                }
                return _buildAnalyticsContent(analytics, productNames);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(DateRangePreset selectedPreset) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نطاق التاريخ',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  DateRangePreset.values
                      .where((p) => p != DateRangePreset.custom)
                      .map(
                        (preset) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildPresetChip(
                            preset,
                            selectedPreset == preset,
                          ),
                        ),
                      )
                      .toList()
                    ..add(
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildCustomRangeButton(
                          selectedPreset == DateRangePreset.custom,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(DateRangePreset preset, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      label: Text(
        preset.arabicLabel,
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          ref.read(selectedDateRangePresetProvider.notifier).state = preset;
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryRed,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryRed : const Color(0xFFE5E7EB),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildCustomRangeButton(bool isSelected) {
    return ActionChip(
      avatar: Icon(
        Icons.calendar_today,
        size: 16,
        color: isSelected ? Colors.white : const Color(0xFF6B7280),
      ),
      label: Text(
        'نطاق مخصص',
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
      onPressed: () => _showCustomDatePicker(),
      backgroundColor: isSelected ? AppTheme.primaryRed : Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryRed : const Color(0xFFE5E7EB),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Future<void> _showCustomDatePicker() async {
    final now = DateTime.now();
    final existingRange = ref.read(customDateRangeProvider);
    final initialStart =
        existingRange?.start ?? now.subtract(const Duration(days: 30));
    final initialEnd = existingRange?.end ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'اختر نطاق التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      saveText: 'حفظ',
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate: end >= start and no future dates
      if (picked.end.isBefore(picked.start)) {
        _showValidationError(
          'تاريخ النهاية يجب أن يكون بعد أو يساوي تاريخ البداية',
        );
        return;
      }
      if (picked.end.isAfter(now)) {
        _showValidationError('لا يمكن تحديد تواريخ مستقبلية');
        return;
      }

      ref.read(customDateRangeProvider.notifier).state = AnalyticsDateRange(
        start: picked.start,
        end: picked.end,
      );
      ref.read(selectedDateRangePresetProvider.notifier).state =
          DateRangePreset.custom;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات',
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد تذاكر في الفترة المحددة',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
        const SizedBox(height: 16),
        Text(
          'حدث خطأ',
          style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey.shade600),
        ),
        Text(
          error,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnalyticsContent(
    WorkerAnalyticsSummary analytics,
    Map<String, String> productNames,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSummaryCards(analytics),
          const SizedBox(height: 24),

          // Trend indicator
          if (analytics.trend != null) ...[
            _buildTrendCard(analytics.trend!),
            const SizedBox(height: 24),
          ],

          // Charts section
          Text(
            'الرسوم البيانية',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),

          // Line chart - Sales over time
          _buildChartCard(
            title: 'المبيعات اليومية',
            icon: Icons.show_chart,
            color: const Color(0xFF3B82F6),
            child: _buildLineChart(analytics.dailyAnalytics),
          ),
          const SizedBox(height: 16),

          // Bar chart - Tickets per day
          _buildChartCard(
            title: 'التذاكر اليومية',
            icon: Icons.bar_chart,
            color: const Color(0xFF10B981),
            child: _buildBarChart(analytics.dailyAnalytics),
          ),
          const SizedBox(height: 16),

          // Pie chart - Product breakdown
          if (analytics.productBreakdown.isNotEmpty) ...[
            _buildChartCard(
              title: 'توزيع المنتجات',
              icon: Icons.pie_chart,
              color: const Color(0xFF8B5CF6),
              child: _buildPieChart(analytics.productBreakdown, productNames),
            ),
            const SizedBox(height: 24),
          ],

          // Productivity score gauge
          _buildProductivityCard(analytics),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(WorkerAnalyticsSummary analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          title: 'إجمالي المبيعات',
          value: '${analytics.totalSales.toStringAsFixed(0)} ج.م',
          icon: Icons.attach_money,
          color: const Color(0xFF10B981),
        ),
        _buildSummaryCard(
          title: 'عدد التذاكر',
          value: '${analytics.totalTickets}',
          icon: Icons.receipt_long,
          color: const Color(0xFF3B82F6),
          onTap: () => _showDailyTicketsBreakdown(analytics),
        ),
        _buildSummaryCard(
          title: 'متوسط الإنتاجية',
          value: '${analytics.averageProductivityScore.toStringAsFixed(0)}%',
          icon: Icons.trending_up,
          color: const Color(0xFF8B5CF6),
        ),
        _buildSummaryCard(
          title: 'ساعات النشاط',
          value: '${analytics.averageActivityHours.toStringAsFixed(1)} س/يوم',
          icon: Icons.access_time,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  /// Show daily tickets breakdown in a bottom sheet
  void _showDailyTicketsBreakdown(WorkerAnalyticsSummary analytics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تفاصيل التذاكر اليومية',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Daily tickets list
              Expanded(
                child: analytics.dailyAnalytics.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد تذاكر',
                          style: GoogleFonts.cairo(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: analytics.dailyAnalytics.length,
                        itemBuilder: (context, index) {
                          // Show in reverse order (newest first)
                          final day =
                              analytics.dailyAnalytics[analytics
                                      .dailyAnalytics
                                      .length -
                                  1 -
                                  index];
                          return _buildDailyTicketItem(day);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTicketItem(DailyAnalytics day) {
    final dateFormat = DateFormat('EEEE، d MMMM yyyy', 'ar');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTicketsForDay(day),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.date.day}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'ar').format(day.date),
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(day.date),
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${day.ticketCount} تذكرة',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${day.totalSales.toStringAsFixed(0)} ج.م',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show tickets for a specific day
  void _showTicketsForDay(DailyAnalytics day) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تذاكر يوم ${dateFormat.format(day.date)}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '${day.ticketCount} تذكرة - ${day.totalSales.toStringAsFixed(0)} ج.م',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Tickets list
              Expanded(
                child: day.tickets.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد تذاكر في هذا اليوم',
                          style: GoogleFonts.cairo(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: day.tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = day.tickets[index];
                          return _buildTicketItem(ticket);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketItem(TicketInfo ticket) {
    final timeFormat = DateFormat('hh:mm a', 'ar');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to ticket detail - don't close bottom sheets
          // so back button returns to the ticket list
          context.push('/ticket/${ticket.id}');
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.laundryName,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${ticket.saleAmount.toStringAsFixed(0)} ج.م',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(ticket.createdAt),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (ticket.area.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.area,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(TrendData trend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: trend.isImproving
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            trend.isImproving ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.isImproving ? 'أداء متحسن! 🎉' : 'يحتاج لتحسين',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'المبيعات: ${trend.salesTrend >= 0 ? '+' : ''}${trend.salesTrend.toStringAsFixed(1)}% | التذاكر: ${trend.ticketsTrend >= 0 ? '+' : ''}${trend.ticketsTrend.toStringAsFixed(1)}%',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<DailyAnalytics> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات كافية',
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
      );
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.salesAmount);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(
            data.map((d) => d.salesAmount).reduce((a, b) => a > b ? a : b),
          ),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: data.length > 7
                  ? (data.length / 5).ceil().toDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Text(
                    DateFormat('d/M').format(data[index].date),
                    style: GoogleFonts.cairo(fontSize: 9, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF3B82F6),
            barWidth: 3,
            dotData: FlDotData(
              show: data.length <= 14,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF3B82F6),
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  const Color(0xFF3B82F6).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final dayData = data[spot.spotIndex];
                return LineTooltipItem(
                  '${dayData.salesAmount.toStringAsFixed(0)} ج.م\n${DateFormat('d/M').format(dayData.date)}',
                  GoogleFonts.cairo(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<DailyAnalytics> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات كافية',
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length && data.length <= 14) {
                  return Text(
                    DateFormat('d').format(data[index].date),
                    style: GoogleFonts.cairo(fontSize: 9, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
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
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.ticketCount.toDouble(),
                color: const Color(0xFF10B981),
                width: data.length > 14 ? 8 : 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayData = data[groupIndex];
              return BarTooltipItem(
                '${dayData.ticketCount} تذكرة\n${DateFormat('d/M').format(dayData.date)}',
                GoogleFonts.cairo(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, int> productBreakdown,
    Map<String, String> productNames,
  ) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFFF97316),
      const Color(0xFFEC4899),
    ];

    final entries = productBreakdown.entries.take(8).toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: entries.asMap().entries.map((e) {
                final percentage = (e.value.value / total * 100);
                return PieChartSectionData(
                  value: e.value.value.toDouble(),
                  title: '${percentage.toStringAsFixed(0)}%',
                  color: colors[e.key % colors.length],
                  radius: 60,
                  titleStyle: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: entries.asMap().entries.take(5).map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[e.key % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${productNames[e.value.key] ?? 'منتج غير معروف'} (${e.value.value})',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductivityCard(WorkerAnalyticsSummary analytics) {
    final score = analytics.averageProductivityScore;
    final color = score >= 70
        ? const Color(0xFF10B981)
        : score >= 40
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text(
                  score.toStringAsFixed(0),
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معدل الإنتاجية',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 70
                      ? 'أداء ممتاز! استمر في العمل الرائع 💪'
                      : score >= 40
                      ? 'أداء جيد، يمكنك تحسينه أكثر'
                      : 'يحتاج لمزيد من الجهد والتحسين',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getInterval(double maxValue) {
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    return 2000;
  }
}
