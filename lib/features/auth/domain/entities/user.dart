import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;

  String get displayName => '$firstName $lastName'.trim();

  @override
  List<Object> get props => [id, email, firstName, lastName];
}

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  List<Object> get props => [accessToken, refreshToken];
}

class AuthResult extends Equatable {
  const AuthResult.authenticated({
    required this.user,
    required this.tokens,
  }) : requiresTwoFactor = false,
       sessionId = null,
       email = '',
       demoOtpCode = null;

  const AuthResult.twoFactorRequired({
    required this.sessionId,
    this.email = '',
    this.demoOtpCode,
  }) : requiresTwoFactor = true,
       user = null,
       tokens = null;

  final bool requiresTwoFactor;
  final String? sessionId;
  final String email;
  final String? demoOtpCode;
  final User? user;
  final AuthTokens? tokens;

  @override
  List<Object?> get props => [requiresTwoFactor, sessionId, email, demoOtpCode, user, tokens];
}
