import 'package:photo_gallery/models/splashResponseModel.dart';

class LoginResponse {
  final String message;
  final AppUser user;
  final String token;
  final List<Business> businesses;

  LoginResponse({
    required this.message,
    required this.user,
    required this.token,
    required this.businesses,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      user: AppUser.fromJson(json['user']),
      token: json['token'],
      businesses: (json['businesses'] as List)
          .map((e) => Business.fromJson(e))
          .toList(),
    );
  }
}

class AppUser {
  final String id;
  final String userName;
  final String email;

  AppUser({
    required this.id,
    required this.userName,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
    );
  }
}
