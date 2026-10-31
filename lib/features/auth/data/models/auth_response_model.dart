import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';

/// Data transfer model representing the JSON response from the login endpoint.
class AuthResponseModel {
  const AuthResponseModel({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
    this.firstName,
    this.lastName,
    this.gender,
    this.image,
    this.refreshToken,
  });

  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? image;
  final String accessToken;
  final String? refreshToken;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      image: json['image'] as String?,
      // Support both modern 'accessToken' and legacy 'token'
      accessToken: (json['accessToken'] ?? json['token']) as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (gender != null) 'gender': gender,
      if (image != null) 'image': image,
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }

  AuthSession toEntity() {
    return AuthSession(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      image: image,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
