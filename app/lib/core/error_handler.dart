import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized error handler for the Xeemo Management System
class AppErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log an info message
  static void logInfo(String message, [dynamic context]) {
    _logger.i(message, error: context);
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  /// Log a warning message
  static void logWarning(String message, [dynamic context]) {
    _logger.w(message, error: context);
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
  }

  /// Log an error message with optional stack trace
  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('  Details: $error');
      }
      if (stackTrace != null) {
        debugPrint(
          '  Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}',
        );
      }
    }
  }

  /// Log a debug message (only in debug mode)
  static void logDebug(String message, [dynamic context]) {
    _logger.d(message, error: context);
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
    }
  }
}

/// Custom exception for application-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.originalError, this.stackTrace});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(
    super.message, {
    this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
  });

  /// Check if a specific field has an error
  bool hasFieldError(String field) => fieldErrors?.containsKey(field) ?? false;

  /// Get error message for a specific field
  String? getFieldError(String field) => fieldErrors?[field];
}

/// Exception for authentication errors
class AuthenticationException extends AppException {
  AuthenticationException(
    super.message, {
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Exception for network/API errors
class NetworkException extends AppException {
  final int? statusCode;

  NetworkException(
    super.message, {
    this.statusCode,
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Result type for operations that can fail
class Result<T> {
  final T? data;
  final AppException? error;

  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// Map success value to another type
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data as T));
    }
    return Result.failure(error);
  }

  /// Execute a function if success
  void when({
    required void Function(T) success,
    required void Function(AppException) failure,
  }) {
    if (isSuccess && data != null) {
      success(data as T);
    } else if (error != null) {
      failure(error!);
    }
  }
}
