import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/sales_ticket_model.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../core/theme.dart';

/// Screen for managers to view and export tickets
class TicketsDashboardScreen extends ConsumerStatefulWidget {
  const TicketsDashboardScreen({super.key});

  @override
  ConsumerState<TicketsDashboardScreen> createState() =>
      _TicketsDashboardScreenState();
}

class _TicketsDashboardScreenState
    extends ConsumerState<TicketsDashboardScreen> {
  DateTimeRange? _dateRange;
  TicketStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    // Refresh tickets on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketsProvider.notifier).loadAllTickets();
    });
  }

  void _exportTickets() async {
    try {
      final path = await ref
          .read(ticketsProvider.notifier)
          .exportTicketsToExcel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التصدير إلى: $path'),
            action: SnackBarAction(
              label: 'مشاركة',
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(data: AppTheme.darkTheme, child: child!);
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  List<SalesTicket> _getFilteredTickets(List<SalesTicket> allTickets) {
    return allTickets.where((ticket) {
      // Filter by status
      if (_filterStatus != null && ticket.status != _filterStatus) {
        return false;
      }

      // Filter by date
      if (_dateRange != null) {
        if (ticket.createdAt.isBefore(_dateRange!.start) ||
            ticket.createdAt.isAfter(
              _dateRange!.end.add(const Duration(days: 1)),
            )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final tickets = _getFilteredTickets(ticketsState.tickets);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التذاكر'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'المنتجات',
            onPressed: () => context.go('/products'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _dateRange == null
                              ? 'تصفية حسب التاريخ'
                              : '${DateFormat('MM/dd').format(_dateRange!.start)} - ${DateFormat('MM/dd').format(_dateRange!.end)}',
                        ),
                        onPressed: _selectDateRange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_dateRange != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _dateRange = null),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('تصدير'),
                      onPressed: tickets.isEmpty ? null : _exportTickets,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatusFilterChip(
                        label: 'الكل',
                        isSelected: _filterStatus == null,
                        onSelected: (selected) {
                          if (selected) setState(() => _filterStatus = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      // _StatusFilterChip(
                      //   label: 'المسودة',
                      //   status: TicketStatus.draft,
                      //   isSelected: _filterStatus == TicketStatus.draft,
                      //   onSelected: (s) => setState(() => _filterStatus = s ? TicketStatus.draft : null),
                      // ),
                      // const SizedBox(width: 8),
                      _StatusFilterChip(
                        label: 'قيد الانتظار',
                        status: TicketStatus.queued,
                        isSelected: _filterStatus == TicketStatus.queued,
                        onSelected: (s) => setState(
                          () => _filterStatus = s ? TicketStatus.queued : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusFilterChip(
                        label: 'تم الإرسال',
                        status: TicketStatus.submitted,
                        isSelected: _filterStatus == TicketStatus.submitted,
                        onSelected: (s) => setState(
                          () =>
                              _filterStatus = s ? TicketStatus.submitted : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusFilterChip(
                        label: 'فشل',
                        status: TicketStatus.failed,
                        isSelected: _filterStatus == TicketStatus.failed,
                        onSelected: (s) => setState(
                          () => _filterStatus = s ? TicketStatus.failed : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(
                  label: 'التذاكر',
                  value: tickets.length.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  label: 'الإجمالي',
                  value: CurrencyFormatter.formatEGP(
                    tickets.fold(0, (sum, t) => sum + t.saleAmount),
                  ),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ticketsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _dateRange != null || _filterStatus != null
                              ? 'لا توجد تذاكر تطابق عامل التصفية'
                              : 'لا توجد تذاكر حتى الآن',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        if (_dateRange == null && _filterStatus == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'ستظهر التذاكر التي ينشئها الموظفون هنا',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(ticketsProvider.notifier).loadAllTickets();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return _TicketCard(ticket: ticket);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final TicketStatus? status;
  final bool isSelected;
  final Function(bool) onSelected;

  const _StatusFilterChip({
    required this.label,
    this.status,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: status == null
          ? Theme.of(context).colorScheme.primaryContainer
          : _getStatusColor(status!).withValues(alpha: 0.3),
      checkmarkColor: status == null
          ? Theme.of(context).colorScheme.primary
          : _getStatusColor(status!),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.draft:
        return Colors.grey;
      case TicketStatus.queued:
        return Colors.orange;
      case TicketStatus.submitted:
        return Colors.green;
      case TicketStatus.failed:
        return Colors.red;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SalesTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/ticket/${ticket.ticketId}'),
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  ticket.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _StatusBadge(status: ticket.status),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(dateFormat.format(ticket.createdAt)),
                const SizedBox(width: 16),
                Text(
                  CurrencyFormatter.formatEGP(ticket.saleAmount),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.phone,
                    label: 'الهاتف',
                    value: ticket.clientPhone,
                  ),
                  if (ticket.workerNotes.isNotEmpty)
                    _DetailRow(
                      icon: Icons.note,
                      label: 'ملاحظات الموظف',
                      value: ticket.workerNotes,
                    ),
                  if (ticket.clientNotes.isNotEmpty)
                    _DetailRow(
                      icon: Icons.comment,
                      label: 'ملاحظات العميل',
                      value: ticket.clientNotes,
                    ),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'الموقع',
                    value:
                        '${ticket.latitude.toStringAsFixed(5)}, ${ticket.longitude.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'المنتجات:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...ticket.products.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '• ID: ${p.productId.substring(0, 6)}... (x${p.quantity})',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case TicketStatus.draft:
        color = Colors.grey;
        text = 'مسودة';
        break;
      case TicketStatus.queued:
        color = Colors.orange;
        text = 'قيد الانتظار';
        break;
      case TicketStatus.submitted:
        color = Colors.green;
        text = 'تم الإرسال';
        break;
      case TicketStatus.failed:
        color = Colors.red;
        text = 'فشل';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
