import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sales_ticket_model.dart';
import 'supabase_service.dart';

/// Service for managing offline ticket queue using Hive
class TicketQueueService {
  static const String _boxName = 'ticket_queue';
  Box<String>? _box;

  /// Initialize the Hive box for ticket storage
  Future<void> init() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      SupabaseService.logInfo('Ticket queue initialized');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to initialize ticket queue', e, stackTrace);
      rethrow;
    }
  }

  /// Get the Hive box, initializing if needed
  Future<Box<String>> get _getBox async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  /// Add a ticket to the offline queue
  Future<void> queueTicket(SalesTicket ticket) async {
    try {
      final box = await _getBox;
      final json = jsonEncode(ticket.toJson());
      await box.put(ticket.ticketId, json);
      SupabaseService.logInfo('Ticket queued: ${ticket.ticketId}');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to queue ticket', e, stackTrace);
      rethrow;
    }
  }

  /// Get all queued tickets
  Future<List<SalesTicket>> getQueuedTickets() async {
    try {
      final box = await _getBox;
      final tickets = <SalesTicket>[];
      
      for (final key in box.keys) {
        final json = box.get(key);
        if (json != null) {
          try {
            final map = jsonDecode(json) as Map<String, dynamic>;
            tickets.add(SalesTicket.fromJson(map));
          } catch (e) {
            SupabaseService.logWarning('Failed to parse ticket $key: $e');
          }
        }
      }
      
      return tickets;
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to get queued tickets', e, stackTrace);
      return [];
    }
  }

  /// Remove a ticket from the queue (after successful sync)
  Future<void> removeTicket(String ticketId) async {
    try {
      final box = await _getBox;
      await box.delete(ticketId);
      SupabaseService.logInfo('Ticket removed from queue: $ticketId');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to remove ticket from queue', e, stackTrace);
    }
  }

  /// Update a ticket's status in the queue
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      final box = await _getBox;
      final json = box.get(ticketId);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        map['status'] = status.name;
        await box.put(ticketId, jsonEncode(map));
      }
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to update ticket status', e, stackTrace);
    }
  }

  /// Get count of queued tickets
  Future<int> getQueuedCount() async {
    try {
      final box = await _getBox;
      return box.length;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all queued tickets
  Future<void> clearQueue() async {
    try {
      final box = await _getBox;
      await box.clear();
      SupabaseService.logInfo('Ticket queue cleared');
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to clear ticket queue', e, stackTrace);
    }
  }
}
