import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateUsername', () {
      test('returns error when null or empty', () {
        expect(Validators.validateUsername(null), 'Username is required');
        expect(Validators.validateUsername(''), 'Username is required');
        expect(Validators.validateUsername('   '), 'Username is required');
      });

      test('returns error when less than 3 characters', () {
        expect(
          Validators.validateUsername('ab'),
          'Username must be at least 3 characters',
        );
      });

      test('returns null when valid', () {
        expect(Validators.validateUsername('emilys'), isNull);
        expect(Validators.validateUsername('user123'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when null or empty', () {
        expect(Validators.validatePassword(null), 'Password is required');
        expect(Validators.validatePassword(''), 'Password is required');
      });

      test('returns error when less than 6 characters', () {
        expect(
          Validators.validatePassword('12345'),
          'Password must be at least 6 characters',
        );
      });

      test('returns null when valid', () {
        expect(Validators.validatePassword('emilyspass'), isNull);
        expect(Validators.validatePassword('securePassword123!'), isNull);
      });
    });
  });
}
