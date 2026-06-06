import '../services/supabase_service.dart';
import '../config/app_config.dart';

/// Model for manager-worker assignment
class ManagerWorkerAssignment {
  final String id;
  final String managerId;
  final String workerId;
  final DateTime createdAt;
  final String? createdBy;

  ManagerWorkerAssignment({
    required this.id,
    required this.managerId,
    required this.workerId,
    required this.createdAt,
    this.createdBy,
  });

  factory ManagerWorkerAssignment.fromJson(Map<String, dynamic> json) {
    return ManagerWorkerAssignment(
      id: json['id'] as String,
      managerId: json['manager_id'] as String,
      workerId: json['worker_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'manager_id': managerId,
    'worker_id': workerId,
    'created_by': createdBy,
  };
}

/// Service for managing manager-worker assignments
class ManagerAssignmentsService {
  static const String _tableName = 'manager_worker_assignments';

  /// Get all workers assigned to a specific manager
  Future<List<String>> getAssignedWorkerIds(String managerId) async {
    if (!AppConfig.isSupabaseConfigured) {
      SupabaseService.logWarning('Supabase not configured');
      return [];
    }

    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select('worker_id')
          .eq('manager_id', managerId);

      return (response as List)
          .map((row) => row['worker_id'] as String)
          .toList();
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to get assigned workers', e, stackTrace);
      return [];
    }
  }

  /// Get all assignments for a manager
  Future<List<ManagerWorkerAssignment>> getAssignments(String managerId) async {
    if (!AppConfig.isSupabaseConfigured) {
      return [];
    }

    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('manager_id', managerId);

      return (response as List)
          .map(
            (json) =>
                ManagerWorkerAssignment.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to get assignments', e, stackTrace);
      return [];
    }
  }

  /// Get all assignments (for super_manager)
  Future<List<ManagerWorkerAssignment>> getAllAssignments() async {
    if (!AppConfig.isSupabaseConfigured) {
      return [];
    }

    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (json) =>
                ManagerWorkerAssignment.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to get all assignments', e, stackTrace);
      return [];
    }
  }

  /// Assign a worker to a manager
  Future<bool> assignWorker({
    required String managerId,
    required String workerId,
    String? createdBy,
  }) async {
    if (!AppConfig.isSupabaseConfigured) {
      SupabaseService.logWarning('Supabase not configured');
      return false;
    }

    try {
      await SupabaseService.client.from(_tableName).insert({
        'manager_id': managerId,
        'worker_id': workerId,
        'created_by': createdBy,
      });

      SupabaseService.logInfo(
        'Assigned worker $workerId to manager $managerId',
      );
      return true;
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to assign worker', e, stackTrace);
      return false;
    }
  }

  /// Remove worker assignment from a manager
  Future<bool> unassignWorker({
    required String managerId,
    required String workerId,
  }) async {
    if (!AppConfig.isSupabaseConfigured) {
      return false;
    }

    try {
      await SupabaseService.client
          .from(_tableName)
          .delete()
          .eq('manager_id', managerId)
          .eq('worker_id', workerId);

      SupabaseService.logInfo(
        'Unassigned worker $workerId from manager $managerId',
      );
      return true;
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to unassign worker', e, stackTrace);
      return false;
    }
  }

  /// Get all workers (for assignment UI)
  Future<List<Map<String, dynamic>>> getAllWorkers() async {
    if (!AppConfig.isSupabaseConfigured) {
      return [];
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('user_id, name, email')
          .eq('role', 'worker');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to get workers', e, stackTrace);
      return [];
    }
  }

  /// Get all managers (for assignment UI)
  Future<List<Map<String, dynamic>>> getAllManagers() async {
    if (!AppConfig.isSupabaseConfigured) {
      return [];
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('user_id, name, email, role')
          .or('role.eq.manager,role.eq.super_manager');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      SupabaseService.logError('Failed to get managers', e, stackTrace);
      return [];
    }
  }
}
