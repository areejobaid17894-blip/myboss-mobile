import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/auth/domain/entities/user.dart';
import 'package:myboss_mobile/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:myboss_mobile/features/auth/domain/usecases/verify_two_factor_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInUseCase signInUseCase,
    required VerifyTwoFactorUseCase verifyTwoFactorUseCase,
    required ResendOtpUseCase resendOtpUseCase,
  })  : _signInUseCase = signInUseCase,
        _verifyTwoFactorUseCase = verifyTwoFactorUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        super(const AuthInitial()) {
    on<SignInRequested>(_onSignIn);
    on<VerifyTwoFactorRequested>(_onVerifyTwoFactor);
    on<ResendOtpRequested>(_onResendOtp);
    on<SignOutRequested>(_onSignOut);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final SignInUseCase _signInUseCase;
  final VerifyTwoFactorUseCase _verifyTwoFactorUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _signInUseCase(email: event.email);

    if (response.failure != null) {
      emit(AuthError(failure: response.failure!));
      return;
    }

    final result = response.result!;
    emit(AuthTwoFactorRequired(
      sessionId: result.sessionId!,
      email: result.email,
      demoOtpCode: result.demoOtpCode,
    ));
  }

  Future<void> _onVerifyTwoFactor(VerifyTwoFactorRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _verifyTwoFactorUseCase(
      sessionId: event.sessionId,
      code: event.code,
    );

    if (response.failure != null) {
      emit(AuthError(failure: response.failure!));
      return;
    }

    emit(AuthAuthenticated(user: response.result!.user!));
  }

  Future<void> _onResendOtp(ResendOtpRequested event, Emitter<AuthState> emit) async {
    final currentEmail = state is AuthTwoFactorRequired
        ? (state as AuthTwoFactorRequired).email
        : '';

    final response = await _resendOtpUseCase(sessionId: event.sessionId);

    if (response.failure != null) {
      emit(AuthError(failure: response.failure!));
      return;
    }

    emit(AuthOtpResent(
      sessionId: event.sessionId,
      email: currentEmail,
      demoOtpCode: response.demoOtpCode,
    ));
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthInitial());
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }
}
