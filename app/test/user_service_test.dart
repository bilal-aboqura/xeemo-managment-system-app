import 'package:flutter_test/flutter_test.dart';
import 'package:xeemo_sales/services/user_service.dart';

void main() {
  group('UserService.validatePassword', () {
    test('should return error for password less than 8 characters', () {
      final result = UserService.validatePassword('');
      expect(result, isNotNull);
      expect(result, contains('8'));
    });

    test('should return error for short password', () {
      final result = UserService.validatePassword('Abc123');
      expect(result, isNotNull);
      expect(result, contains('8'));
    });

    test('should return error for password without uppercase', () {
      final result = UserService.validatePassword('abcdefgh1');
      expect(result, isNotNull);
      expect(result, contains('كبير'));
    });

    test('should return error for password without lowercase', () {
      final result = UserService.validatePassword('ABCDEFGH1');
      expect(result, isNotNull);
      expect(result, contains('صغير'));
    });

    test('should return error for password without number', () {
      final result = UserService.validatePassword('Abcdefghi');
      expect(result, isNotNull);
      expect(result, contains('رقم'));
    });

    test('should return null for valid password', () {
      final result = UserService.validatePassword('Password123');
      expect(result, isNull);
    });
  });

  group('UserService.getPasswordStrength', () {
    test('should return 0 for empty password', () {
      final result = UserService.getPasswordStrength('');
      expect(result, 0);
    });

    test('should return 1 for password with only uppercase requirement', () {
      final result = UserService.getPasswordStrength('A');
      expect(result, 1); // Only uppercase
    });

    test('should return 2 for password with length and lowercase', () {
      final result = UserService.getPasswordStrength('abcdefgh');
      expect(result, 2); // Length + lowercase
    });

    test(
      'should return 3 for password with length, lowercase, and uppercase',
      () {
        final result = UserService.getPasswordStrength('Abcdefgh');
        expect(result, 3);
      },
    );

    test('should return 4 for password meeting all requirements', () {
      final result = UserService.getPasswordStrength('Abcdefg1');
      expect(result, 4);
    });
  });

  group('UserService.validateEmail', () {
    test('should return error for empty email', () {
      final result = UserService.validateEmail('');
      expect(result, isNotNull);
      expect(result, contains('مطلوب'));
    });

    test('should return error for invalid email format', () {
      expect(UserService.validateEmail('invalid'), isNotNull);
      expect(UserService.validateEmail('invalid@'), isNotNull);
      expect(UserService.validateEmail('@domain.com'), isNotNull);
      expect(UserService.validateEmail('user@.com'), isNotNull);
    });

    test('should return null for valid email', () {
      expect(UserService.validateEmail('user@example.com'), isNull);
      expect(UserService.validateEmail('first.last@company.org'), isNull);
      expect(UserService.validateEmail('user123@test.co'), isNull);
    });
  });

  group('UserService.validateName', () {
    test('should return error for empty name', () {
      final result = UserService.validateName('');
      expect(result, isNotNull);
      expect(result, contains('مطلوب'));
    });

    test('should return error for name too short', () {
      final result = UserService.validateName('A');
      expect(result, isNotNull);
      expect(result, contains('حرفين'));
    });

    test('should return null for valid name', () {
      expect(UserService.validateName('Ahmed'), isNull);
      expect(UserService.validateName('محمد أحمد'), isNull);
      expect(UserService.validateName('ABC'), isNull);
    });
  });
}
