part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class SignInRequested extends AuthEvent {
  const SignInRequested({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

final class VerifyTwoFactorRequested extends AuthEvent {
  const VerifyTwoFactorRequested({required this.sessionId, required this.code});

  final String sessionId;
  final String code;

  @override
  List<Object> get props => [sessionId, code];
}

final class ResendOtpRequested extends AuthEvent {
  const ResendOtpRequested({required this.sessionId});

  final String sessionId;

  @override
  List<Object> get props => [sessionId];
}

final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

final class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
