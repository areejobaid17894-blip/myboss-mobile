part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}

final class AuthTwoFactorRequired extends AuthState {
  const AuthTwoFactorRequired({
    required this.sessionId,
    required this.email,
    this.demoOtpCode,
  });

  final String sessionId;
  final String email;
  final String? demoOtpCode;

  @override
  List<Object?> get props => [sessionId, email, demoOtpCode];
}

final class AuthOtpResent extends AuthState {
  const AuthOtpResent({
    required this.sessionId,
    required this.email,
    this.demoOtpCode,
  });

  final String sessionId;
  final String email;
  final String? demoOtpCode;

  @override
  List<Object?> get props => [sessionId, email, demoOtpCode];
}

final class AuthError extends AuthState {
  const AuthError({required this.failure});

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
