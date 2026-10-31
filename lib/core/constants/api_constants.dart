/// API endpoints and network configuration constants for DummyJSON.
class ApiConstants {
  const ApiConstants._();

  /// Base URL for the DummyJSON API.
  static const String baseUrl = 'https://dummyjson.com';

  /// Authentication endpoints.
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';

  /// Products endpoints.
  static const String productsEndpoint = '/products';

  /// Helper to build a product details endpoint path.
  static String productDetailsEndpoint(int id) => '/products/$id';

  /// Network timeout configurations.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Pagination defaults.
  static const int defaultPageLimit = 15;

  /// API Request parameter and query keys.
  static const String paramLimit = 'limit';
  static const String paramSkip = 'skip';
  static const String paramUsername = 'username';
  static const String paramPassword = 'password';
  static const String paramRefreshToken = 'refreshToken';
  static const String paramExpiresInMins = 'expiresInMins';
}
