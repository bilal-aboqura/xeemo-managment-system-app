import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/sales_ticket_model.dart';

/// Widget to display worker visit statistics
class WorkerStatsWidget extends StatelessWidget {
  final List<SalesTicket> tickets;

  const WorkerStatsWidget({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final workerStats = _calculateWorkerStats();

    if (workerStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'إحصائيات المناديب',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...workerStats.entries.map((entry) => _buildWorkerStatRow(entry)),
        ],
      ),
    );
  }

  Map<String, _WorkerStatData> _calculateWorkerStats() {
    final Map<String, _WorkerStatData> stats = {};

    for (final ticket in tickets) {
      final workerId = ticket.workerId;
      final workerName = ticket.workerName.isNotEmpty
          ? ticket.workerName
          : 'عامل غير معروف';

      if (stats.containsKey(workerId)) {
        stats[workerId] = _WorkerStatData(
          name: workerName,
          visitCount: stats[workerId]!.visitCount + 1,
          totalSales: stats[workerId]!.totalSales + ticket.saleAmount,
        );
      } else {
        stats[workerId] = _WorkerStatData(
          name: workerName,
          visitCount: 1,
          totalSales: ticket.saleAmount,
        );
      }
    }

    // Sort by visit count descending
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.visitCount.compareTo(a.value.visitCount));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildWorkerStatRow(MapEntry<String, _WorkerStatData> entry) {
    final workerId = entry.key;
    final stat = entry.value;

    return GestureDetector(
      onTap: () {
        debugPrint('🔥 WorkerStatsWidget: Worker tapped - ${stat.name} ($workerId)');
        debugPrint(
          '🔥 Attempting navigation to: /worker-detail/$workerId/${Uri.encodeComponent(stat.name)}',
        );
        // Note: This widget doesn't have access to context directly
        // We need to use Builder to get context
      },
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              debugPrint(
                '🔥 WorkerStatsWidget: Worker tapped - ${stat.name} ($workerId)',
              );
              debugPrint(
                '🔥 Navigating to: /worker-detail/$workerId/${Uri.encodeComponent(stat.name)}',
              );
              context.push(
                '/worker-detail/$workerId/${Uri.encodeComponent(stat.name)}',
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.2),
                          const Color(0xFF059669).withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        stat.name.isNotEmpty ? stat.name[0].toUpperCase() : '?',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
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
                          stat.name,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إجمالي المبيعات: ${stat.totalSales.toStringAsFixed(0)} ج.م',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${stat.visitCount} زيارة',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WorkerStatData {
  final String name;
  final int visitCount;
  final double totalSales;

  _WorkerStatData({
    required this.name,
    required this.visitCount,
    required this.totalSales,
  });
}
