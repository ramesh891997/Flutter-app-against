import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/network/network_exceptions.dart';

void main() {
  group('NetworkExceptionHandler', () {
    test('maps connection timeout to NetworkException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = NetworkExceptionHandler.handle(dioException);

      expect(exception, isA<NetworkException>());
    });

    test('maps 400 Invalid credentials to AuthException with code 400', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 400,
          data: {'message': 'Invalid credentials'},
        ),
      );

      final exception = NetworkExceptionHandler.handle(dioException);

      expect(exception, isA<AuthException>());
      expect(exception.message, contains('Invalid credentials'));
      expect(exception.statusCode, 400);
    });

    test('maps 401 unauthorized to AuthException with code 401', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/protected'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/protected'),
          statusCode: 401,
          data: {'message': 'Invalid/Expired Token!'},
        ),
      );

      final exception = NetworkExceptionHandler.handle(dioException);

      expect(exception, isA<AuthException>());
      expect(exception.statusCode, 401);
    });

    test('maps 500 server error to ServerException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/products'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/products'),
          statusCode: 500,
        ),
      );

      final exception = NetworkExceptionHandler.handle(dioException);

      expect(exception, isA<ServerException>());
      expect(exception.statusCode, 500);
    });

    test('maps socket error to NetworkException', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/products'),
        type: DioExceptionType.unknown,
        message: 'SocketException: OS Error: Connection refused',
      );

      final exception = NetworkExceptionHandler.handle(dioException);

      expect(exception, isA<NetworkException>());
    });
  });
}
