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
    final hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

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

    // Check connectivity before starting
    if (!await hasConnectivity()) {
      SupabaseService.logWarning('No connectivity, skipping sync');
      return SyncResult(synced: 0, failed: 0, pending: -1);
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
          await _syncTicketWithRetry(ticket);
          await _queueService.removeTicket(ticket.ticketId);
          synced++;
          SupabaseService.logInfo('Synced ticket: ${ticket.ticketId}');
        } catch (e) {
          failed++;
          await _queueService.updateTicketStatus(
            ticket.ticketId,
            TicketStatus.failed,
          );
          SupabaseService.logError(
            'Failed to sync ticket: ${ticket.ticketId}',
            e,
          );
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

  /// Sync a single ticket with retry logic (exponential backoff)
  Future<void> _syncTicketWithRetry(
    SalesTicket ticket, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 1);

    while (attempt < maxRetries) {
      try {
        await _syncTicket(ticket).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException(
              'Sync timeout for ticket ${ticket.ticketId}',
            );
          },
        );
        return; // Success, exit retry loop
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          SupabaseService.logError(
            'Failed to sync ticket after $maxRetries attempts: ${ticket.ticketId}',
            e,
          );
          rethrow;
        }

        SupabaseService.logWarning(
          'Sync attempt $attempt failed for ${ticket.ticketId}, retrying in ${delay.inSeconds}s',
        );

        // Wait before retry with exponential backoff
        await Future.delayed(delay);
        delay *= 2; // Double the delay for next retry
      }
    }
  }

  /// Sync a single ticket to the server
  Future<void> _syncTicket(SalesTicket ticket) async {
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
