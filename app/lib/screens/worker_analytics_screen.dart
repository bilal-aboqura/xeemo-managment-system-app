import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/worker_analytics_provider.dart';
import '../providers/ticket_provider.dart';
import '../services/excel_export_service.dart';
import '../core/theme.dart';

/// Screen for detailed worker analytics
class WorkerAnalyticsScreen extends ConsumerWidget {
  const WorkerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAnalytics = ref.watch(allWorkersAnalyticsProvider);
    final ticketsState = ref.watch(ticketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 141, 17, 17), Color(0xFF6E0A0A)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'تحليلات المناديب',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Export Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _exportAnalytics(context, allAnalytics),
                      tooltip: 'تصدير Excel',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ticketsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : allAnalytics.isEmpty
          ? Center(
              child: Text(
                'لا توجد بيانات',
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allAnalytics.length,
              itemBuilder: (context, index) {
                return _WorkerAnalyticsCard(
                  analytics: allAnalytics[index],
                  rank: index + 1,
                );
              },
            ),
    );
  }

  Future<void> _exportAnalytics(
    BuildContext context,
    List<WorkerAnalytics> analytics,
  ) async {
    try {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final path = await ExcelExportService().exportWorkerAnalytics(analytics);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التصدير: $path', style: GoogleFonts.cairo()),
          action: SnackBarAction(
            label: 'مشاركة',
            onPressed: () => ExcelExportService().shareFile(path),
          ),
        ),
      );

      await ExcelExportService().shareFile(path);
    } catch (e) {
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التصدير: $e', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _WorkerAnalyticsCard extends StatelessWidget {
  final WorkerAnalytics analytics;
  final int rank;

  const _WorkerAnalyticsCard({required this.analytics, required this.rank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint(
          '🔥 Worker card tapped: ${analytics.workerName} (${analytics.workerId})',
        );
        context.push(
          '/worker-analytics-detail/${analytics.workerId}/${Uri.encodeComponent(analytics.workerName)}',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: rank <= 3
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                      : [
                          AppTheme.primaryRed.withValues(alpha: 0.8),
                          AppTheme.primaryRed,
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Worker info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analytics.workerName,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatBadge(
                        '${analytics.ticketCount} زيارة',
                        const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 8),
                      _buildStatBadge(
                        '${analytics.totalSales.toStringAsFixed(0)} ج.م',
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
