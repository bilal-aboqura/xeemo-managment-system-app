import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/sales_ticket_model.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../core/theme.dart';

/// Home screen for workers showing their tickets
class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketsProvider.notifier).loadWorkerTickets();
    });
  }

  Future<void> _refresh() async {
    await ref.read(ticketsProvider.notifier).loadWorkerTickets();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate stats
    final todayTickets = ticketsState.tickets.where((t) {
      final now = DateTime.now();
      return t.createdAt.year == now.year &&
          t.createdAt.month == now.month &&
          t.createdAt.day == now.day;
    }).length;

    final totalSales = ticketsState.tickets.fold<double>(
      0,
      (sum, t) => sum + t.saleAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تذاكري'),
            if (user != null)
              Text(
                'مرحباً ${user.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(
                  label: 'إجمالي التذاكر',
                  value: '${ticketsState.tickets.length}',
                  icon: Icons.receipt_long,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'تذاكر اليوم',
                  value: '$todayTickets',
                  icon: Icons.today,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'إجمالي المبيعات',
                  value: CurrencyFormatter.formatEGP(totalSales),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Tickets List
          Expanded(
            child: ticketsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ticketsState.tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد تذاكر حتى الآن',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على + لإنشاء تذكرة جديدة',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: ticketsState.tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = ticketsState.tickets[index];
                        return _TicketListItem(ticket: ticket);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-ticket'),
        icon: const Icon(Icons.add),
        label: const Text('تذكرة جديدة'),
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketListItem extends StatelessWidget {
  final SalesTicket ticket;

  const _TicketListItem({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy - hh:mm a', 'ar');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/ticket/${ticket.ticketId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ticket.clientPhone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.formatEGP(ticket.saleAmount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(ticket.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (ticket.products.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.products.length} منتجات',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
        text = 'في الانتظار';
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
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
