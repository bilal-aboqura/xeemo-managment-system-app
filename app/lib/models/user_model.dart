import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User roles for RBAC
enum UserRole {
  @JsonValue('worker')
  worker,
  @JsonValue('manager')
  manager,
  @JsonValue('super_manager')
  superManager,
}

/// User model representing a user in the system
@freezed
class User with _$User {
  /// Private constructor for adding methods
  const User._();

  const factory User({
    /// Unique identifier for the user (UUID from Supabase)
    required String userId,

    /// User's display name
    required String name,

    /// User's email address
    required String email,

    /// User's role (worker, manager, or super_manager)
    required UserRole role,

    /// When the user profile was created
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Check if the user is a worker
  bool get isWorker => role == UserRole.worker;

  /// Check if the user is a manager (includes super_manager)
  bool get isManager =>
      role == UserRole.manager || role == UserRole.superManager;

  /// Check if the user is a super manager (admin)
  bool get isSuperManager => role == UserRole.superManager;
}
