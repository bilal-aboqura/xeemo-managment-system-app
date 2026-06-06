import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_ticket_model.dart';
import '../services/supabase_service.dart';
import '../services/excel_export_service.dart';
import '../config/app_config.dart';
import 'auth_provider.dart';

/// State for tickets list
class TicketsState {
  final List<SalesTicket> tickets;
  final bool isLoading;
  final String? error;

  const TicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
  });

  TicketsState copyWith({
    List<SalesTicket>? tickets,
    bool? isLoading,
    String? error,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing tickets state
class TicketsNotifier extends StateNotifier<TicketsState> {
  final Ref _ref;

  TicketsNotifier(this._ref) : super(const TicketsState());

  /// Load all tickets from database (Manager only)
  /// - super_manager: sees all tickets
  /// - manager: sees only tickets from assigned workers
  Future<void> loadAllTickets() async {
    if (!AppConfig.isSupabaseConfigured) {
      SupabaseService.logWarning('Supabase not configured, using mock tickets');
      state = TicketsState(tickets: _getMockTickets(), isLoading: false);
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _ref.read(currentUserProvider);
      List<SalesTicket> tickets = [];

      if (user?.isSuperManager == true) {
        // Super manager sees all tickets
        final response = await SupabaseService.client
            .from('tickets')
            .select()
            .order('created_at', ascending: false);

        tickets = (response as List)
            .map((json) => _parseTicket(json as Map<String, dynamic>))
            .toList();
      } else if (user?.isManager == true) {
        // Regular manager sees only assigned workers' tickets
        final assignedWorkerIds = await _getAssignedWorkerIds(user!.userId);

        if (assignedWorkerIds.isEmpty) {
          // No workers assigned, show empty
          tickets = [];
        } else {
          // Fetch tickets from assigned workers
          final response = await SupabaseService.client
              .from('tickets')
              .select()
              .inFilter('worker_id', assignedWorkerIds)
              .order('created_at', ascending: false);

          tickets = (response as List)
              .map((json) => _parseTicket(json as Map<String, dynamic>))
              .toList();
        }
      }

      state = TicketsState(tickets: tickets, isLoading: false);
      SupabaseService.logInfo('Loaded ${tickets.length} tickets');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to load tickets', e, stackTrace);
      state = TicketsState(error: e.toString(), isLoading: false);
    }
  }

  /// Get worker IDs assigned to the current manager
  Future<List<String>> _getAssignedWorkerIds(String managerId) async {
    try {
      final response = await SupabaseService.client
          .from('manager_worker_assignments')
          .select('worker_id')
          .eq('manager_id', managerId);

      return (response as List)
          .map((row) => row['worker_id'] as String)
          .toList();
    } catch (e) {
      SupabaseService.logError('Failed to get assigned workers', e);
      return [];
    }
  }

  /// Load tickets for current worker
  Future<void> loadWorkerTickets() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    if (!AppConfig.isSupabaseConfigured) {
      state = TicketsState(
        tickets: _getMockTickets()
            .where((t) => t.workerId == user.userId)
            .toList(),
        isLoading: false,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await SupabaseService.client
          .from('tickets')
          .select()
          .eq('worker_id', user.userId)
          .order('created_at', ascending: false);

      final tickets = (response as List)
          .map((json) => _parseTicket(json as Map<String, dynamic>))
          .toList();

      state = TicketsState(tickets: tickets, isLoading: false);
      SupabaseService.logInfo('Loaded ${tickets.length} worker tickets');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to load worker tickets', e, stackTrace);
      state = TicketsState(error: e.toString(), isLoading: false);
    }
  }

  /// Submit a new ticket (Worker only)
  Future<void> submitTicket(SalesTicket ticket) async {
    if (!AppConfig.isSupabaseConfigured) {
      final updatedTicket = ticket.copyWith(status: TicketStatus.submitted);
      state = state.copyWith(tickets: [updatedTicket, ...state.tickets]);
      SupabaseService.logInfo('Ticket submitted (mock): ${ticket.ticketId}');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Convert products to JSON-compatible list
      final productsJson = ticket.products
          .map((p) => {'productId': p.productId, 'quantity': p.quantity})
          .toList();

      await SupabaseService.client.from('tickets').insert({
        'ticket_id': ticket.ticketId,
        'client_name': ticket.clientName,
        'client_phone': ticket.clientPhone,
        'laundry_name': ticket.laundryName,
        'worker_notes': ticket.workerNotes,
        'client_notes': ticket.clientNotes,
        'sale_amount': ticket.saleAmount,
        'worker_id': ticket.workerId,
        'worker_name': ticket.workerName,
        'latitude': ticket.latitude,
        'longitude': ticket.longitude,
        'created_at': ticket.createdAt.toIso8601String(),
        'status': 'submitted', // Force submitted status
        'products': productsJson, // Save products to JSONB column
      });

      final submittedTicket = ticket.copyWith(status: TicketStatus.submitted);
      state = state.copyWith(
        tickets: [submittedTicket, ...state.tickets],
        isLoading: false,
      );

      SupabaseService.logInfo('Ticket submitted: ${ticket.ticketId}');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to submit ticket', e, stackTrace);
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  /// Export tickets to Excel
  Future<String> exportTicketsToExcel() async {
    final exportService = ExcelExportService();
    return await exportService.exportTicketsToExcel(state.tickets);
  }

  /// Update an existing ticket
  Future<void> updateTicket(SalesTicket updatedTicket) async {
    if (!AppConfig.isSupabaseConfigured) {
      // Update in local state for mock mode
      final updatedTickets = state.tickets.map((t) {
        return t.ticketId == updatedTicket.ticketId ? updatedTicket : t;
      }).toList();
      state = state.copyWith(tickets: updatedTickets);
      SupabaseService.logInfo(
        'Ticket updated (mock): ${updatedTicket.ticketId}',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Convert products to JSON-compatible list
      final productsJson = updatedTicket.products
          .map((p) => {'productId': p.productId, 'quantity': p.quantity})
          .toList();

      await SupabaseService.client
          .from('tickets')
          .update({
            'client_name': updatedTicket.clientName,
            'client_phone': updatedTicket.clientPhone,
            'laundry_name': updatedTicket.laundryName,
            'worker_notes': updatedTicket.workerNotes,
            'client_notes': updatedTicket.clientNotes,
            'sale_amount': updatedTicket.saleAmount,
            'products': productsJson,
          })
          .eq('ticket_id', updatedTicket.ticketId);

      // Update local state
      final updatedTickets = state.tickets.map((t) {
        return t.ticketId == updatedTicket.ticketId ? updatedTicket : t;
      }).toList();

      state = state.copyWith(tickets: updatedTickets, isLoading: false);
      SupabaseService.logInfo('Ticket updated: ${updatedTicket.ticketId}');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to update ticket', e, stackTrace);
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  /// Parse ticket from database response
  SalesTicket _parseTicket(Map<String, dynamic> json) {
    // Parse products from JSONB
    List<TicketProductEntry> products = [];
    if (json['products'] != null) {
      products = (json['products'] as List).map((p) {
        return TicketProductEntry(
          productId: p['productId'] ?? p['product_id'] ?? '',
          quantity: (p['quantity'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    }

    return SalesTicket(
      ticketId: json['ticket_id'] as String,
      clientName: json['client_name'] as String,
      clientPhone: json['client_phone'] as String,
      laundryName: json['laundry_name'] as String? ?? '',
      workerNotes: json['worker_notes'] as String? ?? '',
      clientNotes: json['client_notes'] as String? ?? '',
      saleAmount: (json['sale_amount'] as num).toDouble(),
      workerId: json['worker_id'] as String,
      workerName: json['worker_name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: _parseStatus(json['status'] as String?),
      products: products,
    );
  }

  TicketStatus _parseStatus(String? status) {
    switch (status) {
      case 'submitted':
        return TicketStatus.submitted;
      case 'failed':
        return TicketStatus.failed;
      case 'queued':
        return TicketStatus.queued;
      default:
        return TicketStatus.draft;
    }
  }

  /// Get mock tickets for development
  List<SalesTicket> _getMockTickets() {
    return [
      SalesTicket(
        ticketId: 'mock-1',
        clientName: 'John Doe',
        clientPhone: '+1234567890',
        workerNotes: 'Sample notes',
        saleAmount: 150.00,
        workerId: 'worker-1',
        latitude: 30.0444,
        longitude: 31.2357,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: TicketStatus.submitted,
        products: [const TicketProductEntry(productId: '1', quantity: 2)],
      ),
      SalesTicket(
        ticketId: 'mock-2',
        clientName: 'Jane Smith',
        clientPhone: '+1987654321',
        saleAmount: 299.99,
        workerId: 'worker-1',
        latitude: 30.0500,
        longitude: 31.2400,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: TicketStatus.submitted,
        products: [
          const TicketProductEntry(productId: '2', quantity: 1),
          const TicketProductEntry(productId: '3', quantity: 1),
        ],
      ),
    ];
  }
}

/// Provider for tickets state
final ticketsProvider = StateNotifierProvider<TicketsNotifier, TicketsState>((
  ref,
) {
  return TicketsNotifier(ref);
});

/// Provider for ticket list
final ticketListProvider = Provider<List<SalesTicket>>((ref) {
  return ref.watch(ticketsProvider).tickets;
});

/// Provider for tickets count
final ticketsCountProvider = Provider<int>((ref) {
  return ref.watch(ticketListProvider).length;
});
