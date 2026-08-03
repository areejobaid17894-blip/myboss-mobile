import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/auth/otp_session_store.dart';
import 'package:myboss_mobile/core/config/demo_credentials.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/core/widgets/otp_input.dart';
import 'package:myboss_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myboss_mobile/features/onboarding/presentation/terms_acceptance_flow.dart';
import 'package:myboss_mobile/features/user/domain/usecases/get_user_usecase.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.sessionId,
    required this.email,
    this.demoOtpCode,
  });

  final String sessionId;
  final String email;
  final String? demoOtpCode;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const _resendSeconds = 42;
  int _countdown = _resendSeconds;
  Timer? _timer;
  String? _errorMessage;
  Failure? _lastFailure;
  bool _isLoading = false;
  String? _demoOtpCode;
  String _otpCode = '';
  final _otpKey = GlobalKey<OtpInputState>();
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _demoOtpCode = isDemoBuild ? widget.demoOtpCode : null;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.sessionId.isEmpty) context.go('/sign-in');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authBloc.close();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _verify(BuildContext context, String code) {
    if (widget.sessionId.isEmpty) {
      setState(() => _errorMessage = AppLocalizations.of(context).errorAuthSessionExpired);
      return;
    }
    if (_isLoading) return;
    setState(() {
      _errorMessage = null;
      _lastFailure = null;
    });
    context.read<AuthBloc>().add(VerifyTwoFactorRequested(sessionId: widget.sessionId, code: code));
  }

  Future<void> _continueAfterAuth(BuildContext context, String userId) async {
    setState(() => _isLoading = true);

    final userResponse = await getIt<GetUserUseCase>().call(userId);
    if (!mounted) return;

    if (userResponse.failure != null || userResponse.profile == null) {
      setState(() => _isLoading = false);
      context.go('/sign-in');
      return;
    }

    final profile = userResponse.profile!;
    getIt<SessionManager>().setUser(profile);

    setState(() => _isLoading = false);
    final acceptedProfile = await ensureTermsAccepted(context, profile);
    if (!mounted) return;
    if (acceptedProfile == null) return;

    context.go('/resolve', extra: userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final l10n = AppLocalizations.of(context);
          final displayError = _lastFailure != null
              ? localizedFailureMessage(l10n, _lastFailure!)
              : _errorMessage;

          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                OtpSessionStore.clear();
                _continueAfterAuth(context, state.user.id);
              } else if (state is AuthOtpResent) {
                _startTimer();
                setState(() {
                  _demoOtpCode = state.demoOtpCode ?? _demoOtpCode;
                  _isLoading = false;
                  _lastFailure = null;
                  _errorMessage = null;
                  _otpCode = '';
                });
                final demoCode = isDemoBuild ? _demoOtpCode : null;
                if (demoCode != null) {
                  _otpKey.currentState?.fillCode(demoCode);
                  setState(() => _otpCode = demoCode);
                } else {
                  _otpKey.currentState?.reset();
                }
              } else if (state is AuthError) {
                _otpKey.currentState?.allowRetry();
                final code = state.failure.code;
                if (code == 'AUTH_INVALID_OTP' && isDemoBuild && _demoOtpCode != null) {
                  _otpKey.currentState?.refill(_demoOtpCode!);
                  setState(() => _otpCode = _demoOtpCode!);
                } else {
                  _otpKey.currentState?.reset();
                  setState(() => _otpCode = '');
                }
                setState(() {
                  _lastFailure = state.failure;
                  _errorMessage = localizedFailureMessage(l10n, state.failure);
                  _isLoading = false;
                });
              } else if (state is AuthLoading) {
                setState(() => _isLoading = true);
              } else if (state is! AuthLoading && state is! AuthError) {
                setState(() => _isLoading = false);
              }
            },
            builder: (context, state) {
              return Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BossTopBar(onBack: () => context.go('/sign-in')),
                    Expanded(
                      child: BossScreenPad(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.otpTitle, style: AppTextStyles.h1),
                            const SizedBox(height: 8),
                            Text(l10n.otpSubtitle(widget.email), style: AppTextStyles.muted),
                            if (isDemoBuild && _demoOtpCode != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${l10n.demoOtpHint}: $_demoOtpCode',
                                style: const TextStyle(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            OtpInput(
                              key: _otpKey,
                              enabled: !_isLoading,
                              initialCode: _demoOtpCode,
                              autoSubmit: false,
                              onChanged: (code) => setState(() => _otpCode = code),
                              onCompleted: (code) => setState(() => _otpCode = code),
                            ),
                            if (displayError != null) ...[
                              const SizedBox(height: 16),
                              Text(displayError, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 14)),
                            ],
                            const SizedBox(height: 24),
                            BossPrimaryButton(
                              label: l10n.verifyAndContinue,
                              variant: BossButtonVariant.ink,
                              isLoading: _isLoading,
                              onPressed: _otpCode.length == 6 && !_isLoading ? () => _verify(context, _otpCode) : null,
                            ),
                            const SizedBox(height: 18),
                            if (_countdown > 0)
                              Text(
                                l10n.resendCodeIn(_formatTime(_countdown)),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.small,
                              )
                            else
                              Center(
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.read<AuthBloc>().add(
                                            ResendOtpRequested(sessionId: widget.sessionId),
                                          ),
                                  child: Text(l10n.resendCode, style: AppTextStyles.link),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
