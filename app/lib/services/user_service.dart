import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as app_models;
import '../config/app_config.dart';
import '../core/error_handler.dart';
import 'supabase_service.dart';

/// Service for user account management (creation, validation, etc.)
class UserService {
  final SupabaseClient _client;

  UserService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  /// Password validation regex patterns
  static final RegExp _hasUpperCase = RegExp(r'[A-Z]');
  static final RegExp _hasLowerCase = RegExp(r'[a-z]');
  static final RegExp _hasNumber = RegExp(r'[0-9]');
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate password strength
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String password) {
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!_hasUpperCase.hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!_hasLowerCase.hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!_hasNumber.hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  /// Check password strength score (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (_hasUpperCase.hasMatch(password)) strength++;
    if (_hasLowerCase.hasMatch(password)) strength++;
    if (_hasNumber.hasMatch(password)) strength++;
    return strength;
  }

  /// Validate email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'الاسم مطلوب';
    }
    if (name.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Create a new worker account
  /// Returns the created user on success
  Future<Result<app_models.User>> createWorker({
    required String name,
    required String email,
    required String password,
    required String createdByUserId,
  }) async {
    return _createUser(
      name: name,
      email: email,
      password: password,
      role: app_models.UserRole.worker,
      createdByUserId: createdByUserId,
    );
  }

  /// Create a new manager account
  /// Returns the created user on success
  Future<Result<app_models.User>> createManager({
    required String name,
    required String email,
    required String password,
    required String createdByUserId,
    String? assignedArea,
  }) async {
    return _createUser(
      name: name,
      email: email,
      password: password,
      role: app_models.UserRole.manager,
      createdByUserId: createdByUserId,
      assignedArea: assignedArea,
    );
  }

  /// Internal method to create a user with specified role
  Future<Result<app_models.User>> _createUser({
    required String name,
    required String email,
    required String password,
    required app_models.UserRole role,
    required String createdByUserId,
    String? assignedArea,
  }) async {
    if (!AppConfig.isSupabaseConfigured) {
      return Result.failure(NetworkException('Supabase غير مهيأ'));
    }

    // Validate fields
    final Map<String, String> fieldErrors = {};

    final nameError = validateName(name);
    if (nameError != null) fieldErrors['name'] = nameError;

    final emailError = validateEmail(email);
    if (emailError != null) fieldErrors['email'] = emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) fieldErrors['password'] = passwordError;

    if (fieldErrors.isNotEmpty) {
      return Result.failure(
        ValidationException('بيانات غير صالحة', fieldErrors: fieldErrors),
      );
    }

    try {
      // Check for duplicate email
      final existingUser = await _client
          .from('profiles')
          .select('user_id')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        return Result.failure(
          ValidationException(
            'البريد الإلكتروني مستخدم بالفعل',
            fieldErrors: {'email': 'البريد الإلكتروني مستخدم بالفعل'},
          ),
        );
      }

      // Create auth user - save current session first
      AppErrorHandler.logInfo('Creating auth user for: $email');

      // Save the current session before creating new user
      final currentSession = _client.auth.currentSession;

      // Sign up the new user using the main client
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        // Restore original session if signup failed
        if (currentSession != null) {
          await _client.auth.setSession(currentSession.refreshToken!);
        }
        return Result.failure(AuthenticationException('فشل إنشاء الحساب'));
      }

      final userId = authResponse.user!.id;

      // Sign out the newly created user
      await _client.auth.signOut();

      // Restore original manager session
      if (currentSession != null) {
        await _client.auth.setSession(currentSession.refreshToken!);
      }

      // Create profile
      AppErrorHandler.logInfo('Creating profile for user: $userId');
      await _client.from('profiles').insert({
        'user_id': userId,
        'name': name,
        'email': email,
        'role': _roleToString(role),
        'created_by': createdByUserId,
        if (assignedArea != null) 'assigned_area': assignedArea,
      });

      final user = app_models.User(
        userId: userId,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      AppErrorHandler.logInfo('User created successfully: ${user.email}');
      return Result.success(user);
    } on AuthException catch (e) {
      AppErrorHandler.logError('Auth error creating user', e);
      return Result.failure(
        AuthenticationException(
          _translateAuthError(e.message),
          originalError: e,
        ),
      );
    } on PostgrestException catch (e) {
      AppErrorHandler.logError('Database error creating user', e);
      return Result.failure(
        NetworkException(_translateDatabaseError(e.message), originalError: e),
      );
    } catch (e, stackTrace) {
      AppErrorHandler.logError('Unexpected error creating user', e, stackTrace);
      return Result.failure(
        AppException('حدث خطأ غير متوقع', originalError: e),
      );
    }
  }

  /// Get all workers
  Future<List<app_models.User>> getAllWorkers() async {
    if (!AppConfig.isSupabaseConfigured) return [];

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('role', 'worker')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _userFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      AppErrorHandler.logError('Failed to get workers', e, stackTrace);
      return [];
    }
  }

  /// Get workers assigned to a specific manager
  Future<List<app_models.User>> getWorkersForManager(String managerId) async {
    if (!AppConfig.isSupabaseConfigured) return [];

    try {
      // First get the worker IDs assigned to this manager
      final assignmentsResponse = await _client
          .from('manager_worker_assignments')
          .select('worker_id')
          .eq('manager_id', managerId);

      if ((assignmentsResponse as List).isEmpty) {
        return [];
      }

      final workerIds = (assignmentsResponse as List)
          .map((a) => a['worker_id'] as String)
          .toList();

      // Then fetch the worker profiles
      final workersResponse = await _client
          .from('profiles')
          .select()
          .inFilter('user_id', workerIds)
          .eq('role', 'worker')
          .order('created_at', ascending: false);

      return (workersResponse as List)
          .map((json) => _userFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      AppErrorHandler.logError(
        'Failed to get workers for manager',
        e,
        stackTrace,
      );
      return [];
    }
  }

  /// Get all managers
  Future<List<app_models.User>> getAllManagers() async {
    if (!AppConfig.isSupabaseConfigured) return [];

    try {
      final response = await _client
          .from('profiles')
          .select()
          .or('role.eq.manager,role.eq.super_manager')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _userFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      AppErrorHandler.logError('Failed to get managers', e, stackTrace);
      return [];
    }
  }

  /// Get all users
  Future<List<app_models.User>> getAllUsers() async {
    if (!AppConfig.isSupabaseConfigured) return [];

    try {
      final response = await _client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _userFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      AppErrorHandler.logError('Failed to get users', e, stackTrace);
      return [];
    }
  }

  /// Convert role enum to string for database
  String _roleToString(app_models.UserRole role) {
    switch (role) {
      case app_models.UserRole.worker:
        return 'worker';
      case app_models.UserRole.manager:
        return 'manager';
      case app_models.UserRole.superManager:
        return 'super_manager';
    }
  }

  /// Parse user from JSON
  app_models.User _userFromJson(Map<String, dynamic> json) {
    final roleString = json['role'] as String? ?? 'worker';
    app_models.UserRole role;
    switch (roleString) {
      case 'super_manager':
        role = app_models.UserRole.superManager;
        break;
      case 'manager':
        role = app_models.UserRole.manager;
        break;
      default:
        role = app_models.UserRole.worker;
    }

    return app_models.User(
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: role,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Translate auth errors to Arabic
  String _translateAuthError(String message) {
    if (message.contains('email already registered')) {
      return 'البريد الإلكتروني مسجل بالفعل';
    }
    if (message.contains('invalid email')) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (message.contains('password')) {
      return 'كلمة المرور ضعيفة جداً';
    }
    return 'فشل إنشاء الحساب: $message';
  }

  /// Translate database errors to Arabic
  String _translateDatabaseError(String message) {
    if (message.contains('duplicate')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }
    if (message.contains('violates')) {
      return 'بيانات غير صالحة';
    }
    return 'خطأ في قاعدة البيانات';
  }

  /// Get user by ID
  Future<app_models.User?> getUserById(String userId) async {
    if (!AppConfig.isSupabaseConfigured) return null;
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return _userFromJson(response);
    } catch (e) {
      AppErrorHandler.logError('Failed to get user by id', e);
      return null;
    }
  }

  /// Update user details
  Future<Result<void>> updateUser({
    required String userId,
    String? name,
    String? password,
  }) async {
    if (!AppConfig.isSupabaseConfigured) {
      return Result.failure(NetworkException('Supabase غير مهيأ'));
    }

    try {
      // 1. Update Profile (Name)
      if (name != null) {
        await _client
            .from('profiles')
            .update({'name': name})
            .eq('user_id', userId);
      }

      // 2. Update Password (if provided)
      if (password != null && password.isNotEmpty) {
        final passwordError = validatePassword(password);
        if (passwordError != null) {
          return Result.failure(ValidationException(passwordError));
        }

        await _client.auth.admin.updateUserById(
          userId,
          attributes: AdminUserAttributes(password: password),
        );
      }

      return Result.success(null);
    } catch (e) {
      AppErrorHandler.logError('Error updating user', e);
      return Result.failure(AppException('فشل تحديث البيانات: $e'));
    }
  }
}
