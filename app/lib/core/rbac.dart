import '../models/user_model.dart';
import '../core/localization.dart';

/// Role-Based Access Control (RBAC) utilities
/// Provides centralized permission checks and access control
class RBAC {
  /// Check if user can create worker accounts
  static bool canCreateWorker(User? user) {
    if (user == null) return false;
    return user.isSuperManager || user.isManager;
  }

  /// Check if user can create manager accounts
  static bool canCreateManager(User? user) {
    if (user == null) return false;
    return user.isSuperManager;
  }

  /// Check if user can view all workers
  static bool canViewWorkerList(User? user) {
    if (user == null) return false;
    return user.isSuperManager || user.isManager;
  }

  /// Check if user can view all managers
  static bool canViewManagerList(User? user) {
    if (user == null) return false;
    return user.isSuperManager;
  }

  /// Check if user can view worker analytics
  static bool canViewWorkerAnalytics(User? user, {String? workerId}) {
    if (user == null) return false;
    // Super managers can view all analytics
    if (user.isSuperManager) return true;
    // Managers can view analytics for their assigned workers
    if (user.isManager) return true;
    // Workers can only view their own analytics
    if (user.isWorker && workerId == user.userId) return true;
    return false;
  }

  /// Check if user can manage assignments
  static bool canManageAssignments(User? user) {
    if (user == null) return false;
    return user.isSuperManager;
  }

  /// Check if user can edit worker account
  static bool canEditWorker(User? user, String workerId) {
    if (user == null) return false;
    if (user.isSuperManager) return true;
    // Managers can edit their assigned workers (would need assignment check)
    if (user.isManager) return true;
    return false;
  }

  /// Check if user can delete worker account
  static bool canDeleteWorker(User? user) {
    if (user == null) return false;
    return user.isSuperManager;
  }

  /// Check if user can access the dashboard
  static bool canAccessDashboard(User? user) {
    if (user == null) return false;
    return user.isSuperManager || user.isManager;
  }

  /// Check if user can manage products
  static bool canManageProducts(User? user) {
    if (user == null) return false;
    return user.isSuperManager || user.isManager;
  }

  /// Get permission error message
  static String getPermissionError(PermissionType type) {
    switch (type) {
      case PermissionType.createWorker:
        return 'ليس لديك صلاحية لإنشاء حسابات المناديب';
      case PermissionType.createManager:
        return AppStrings.superManagerOnly;
      case PermissionType.viewWorkerList:
        return 'ليس لديك صلاحية لعرض قائمة المناديب';
      case PermissionType.viewManagerList:
        return AppStrings.superManagerOnly;
      case PermissionType.viewAnalytics:
        return 'ليس لديك صلاحية لعرض التحليلات';
      case PermissionType.manageAssignments:
        return AppStrings.superManagerOnly;
      case PermissionType.editWorker:
        return 'ليس لديك صلاحية لتعديل هذا الحساب';
      case PermissionType.deleteWorker:
        return AppStrings.superManagerOnly;
      case PermissionType.accessDashboard:
        return 'ليس لديك صلاحية للوصول إلى لوحة التحكم';
      case PermissionType.manageProducts:
        return 'ليس لديك صلاحية لإدارة المنتجات';
    }
  }

  /// Verify permission and throw if denied
  static void requirePermission(
    User? user,
    PermissionType type, {
    String? resourceId,
  }) {
    bool hasPermission;

    switch (type) {
      case PermissionType.createWorker:
        hasPermission = canCreateWorker(user);
        break;
      case PermissionType.createManager:
        hasPermission = canCreateManager(user);
        break;
      case PermissionType.viewWorkerList:
        hasPermission = canViewWorkerList(user);
        break;
      case PermissionType.viewManagerList:
        hasPermission = canViewManagerList(user);
        break;
      case PermissionType.viewAnalytics:
        hasPermission = canViewWorkerAnalytics(user, workerId: resourceId);
        break;
      case PermissionType.manageAssignments:
        hasPermission = canManageAssignments(user);
        break;
      case PermissionType.editWorker:
        hasPermission = canEditWorker(user, resourceId ?? '');
        break;
      case PermissionType.deleteWorker:
        hasPermission = canDeleteWorker(user);
        break;
      case PermissionType.accessDashboard:
        hasPermission = canAccessDashboard(user);
        break;
      case PermissionType.manageProducts:
        hasPermission = canManageProducts(user);
        break;
    }

    if (!hasPermission) {
      throw PermissionDeniedException(getPermissionError(type));
    }
  }
}

/// Types of permissions in the system
enum PermissionType {
  createWorker,
  createManager,
  viewWorkerList,
  viewManagerList,
  viewAnalytics,
  manageAssignments,
  editWorker,
  deleteWorker,
  accessDashboard,
  manageProducts,
}

/// Exception thrown when a permission check fails
class PermissionDeniedException implements Exception {
  final String message;

  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
