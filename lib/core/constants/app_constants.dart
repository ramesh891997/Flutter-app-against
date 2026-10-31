/// Application-wide constants and storage keys.
class AppConstants {
  const AppConstants._();

  /// Application metadata.
  static const String appName = 'Store';

  /// Secure storage keys.
  static const String keyAccessToken = 'auth_access_token';
  static const String keyRefreshToken = 'auth_refresh_token';
  static const String keyUserId = 'auth_user_id';
  static const String keyUsername = 'auth_username';
  static const String keyUserEmail = 'auth_user_email';
  static const String keyUserFirstName = 'auth_user_first_name';
  static const String keyUserLastName = 'auth_user_last_name';
  static const String keyUserAvatar = 'auth_user_avatar';

  /// Pagination scroll threshold in pixels before reaching bottom.
  static const double paginationScrollThreshold = 200.0;
}
