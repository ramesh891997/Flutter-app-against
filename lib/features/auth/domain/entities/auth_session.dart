/// Domain entity representing an authenticated user session.
class AuthSession {
  const AuthSession({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
    this.firstName,
    this.lastName,
    this.image,
    this.refreshToken,
  });

  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String accessToken;
  final String? refreshToken;

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          accessToken == other.accessToken;

  @override
  int get hashCode => Object.hash(id, username, accessToken);
}
