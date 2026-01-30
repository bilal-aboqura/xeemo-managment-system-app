import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/sales_ticket_model.dart';
import '../config/app_config.dart';
import 'supabase_service.dart';
import 'ticket_queue_service.dart';

/// Service for syncing offline tickets when connectivity is restored
class TicketSyncService {
  final TicketQueueService _queueService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  TicketSyncService(this._queueService);

  /// Start listening for connectivity changes
  void startListening() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    SupabaseService.logInfo('Ticket sync service started');
  }

  /// Stop listening for connectivity changes
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    SupabaseService.logInfo('Ticket sync service stopped');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    
    if (hasConnection) {
      SupabaseService.logInfo('Connectivity restored, starting sync');
      syncPendingTickets();
    }
  }

  /// Check current connectivity status
  Future<bool> hasConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Sync all pending tickets to the server
  Future<SyncResult> syncPendingTickets() async {
    if (_isSyncing) {
      SupabaseService.logWarning('Sync already in progress');
      return SyncResult(synced: 0, failed: 0, pending: 0);
    }

    if (!AppConfig.isSupabaseConfigured) {
      SupabaseService.logWarning('Supabase not configured, skipping sync');
      return SyncResult(synced: 0, failed: 0, pending: 0);
    }

    _isSyncing = true;
    int synced = 0;
    int failed = 0;

    try {
      final tickets = await _queueService.getQueuedTickets();
      
      if (tickets.isEmpty) {
        SupabaseService.logInfo('No tickets to sync');
        return SyncResult(synced: 0, failed: 0, pending: 0);
      }

      SupabaseService.logInfo('Syncing ${tickets.length} queued tickets');

      for (final ticket in tickets) {
        try {
          await _syncTicket(ticket);
          await _queueService.removeTicket(ticket.ticketId);
          synced++;
          SupabaseService.logInfo('Synced ticket: ${ticket.ticketId}');
        } catch (e) {
          failed++;
          await _queueService.updateTicketStatus(
            ticket.ticketId, 
            TicketStatus.failed,
          );
          SupabaseService.logError('Failed to sync ticket: ${ticket.ticketId}', e);
        }
      }

      SupabaseService.logInfo('Sync complete: $synced synced, $failed failed');
      
      final remaining = await _queueService.getQueuedCount();
      return SyncResult(synced: synced, failed: failed, pending: remaining);
    } catch (e, stackTrace) {
      SupabaseService.logError('Sync failed', e, stackTrace);
      return SyncResult(synced: synced, failed: failed, pending: -1);
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single ticket to the server
  Future<void> _syncTicket(SalesTicket ticket) async {
    await SupabaseService.client.from('tickets').insert({
      'ticket_id': ticket.ticketId,
      'client_name': ticket.clientName,
      'client_phone': ticket.clientPhone,
      'worker_notes': ticket.workerNotes,
      'client_notes': ticket.clientNotes,
      'sale_amount': ticket.saleAmount,
      'worker_id': ticket.workerId,
      'latitude': ticket.latitude,
      'longitude': ticket.longitude,
      'created_at': ticket.createdAt.toIso8601String(),
    });

    // Insert ticket products
    for (final product in ticket.products) {
      await SupabaseService.client.from('ticket_products').insert({
        'ticket_id': ticket.ticketId,
        'product_id': product.productId,
        'quantity': product.quantity,
      });
    }
  }
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final int pending;

  SyncResult({
    required this.synced,
    required this.failed,
    required this.pending,
  });

  bool get hasFailures => failed > 0;
  bool get hasPending => pending > 0;
  bool get isComplete => pending == 0 && failed == 0;
}
