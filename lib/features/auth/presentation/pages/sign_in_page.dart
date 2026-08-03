import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/config/demo_credentials.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/router/otp_route_args.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_logo.dart';
import 'package:myboss_mobile/features/auth/presentation/bloc/auth_bloc.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final l10n = AppLocalizations.of(context);

          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthTwoFactorRequired) {
                context.go(
                  '/verify-otp',
                  extra: OtpRouteArgs(
                    sessionId: state.sessionId,
                    email: state.email,
                    demoOtpCode: state.demoOtpCode,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final errorMessage = state is AuthError
                  ? localizedFailureMessage(l10n, state.failure)
                  : null;

              return Scaffold(
                body: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: const LanguageToggleButton(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 48),
                            const BossLogo(),
                            const SizedBox(height: 40),
                            Text(l10n.signInTitle, style: AppTextStyles.h1),
                            const SizedBox(height: 8),
                            Text(l10n.signInSubtitle, style: AppTextStyles.muted),
                            if (isDemoBuild) ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _showDemoAccounts(context, l10n),
                                child: Text(l10n.demoAccountLabel, style: AppTextStyles.link),
                              ),
                            ],
                            const SizedBox(height: 22),
                            _SignInForm(
                              isLoading: isLoading,
                              errorMessage: errorMessage,
                              buttonLabel: '${l10n.sendMyCode} →',
                              hintText: l10n.emailHint,
                              onSubmit: (email) {
                                context.read<AuthBloc>().add(SignInRequested(email: email));
                              },
                            ),
                            const Spacer(),
                            Text(
                              l10n.signInFooterHelp,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.small,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDemoAccounts(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.otherTestAccountsTitle, style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(l10n.otherTestAccountsDescription, style: AppTextStyles.small),
            const SizedBox(height: 16),
            ...demoTestAccounts.map(
              (account) => ListTile(
                title: Text(account.label),
                subtitle: Text('${account.email}\n${account.scenario}', style: AppTextStyles.small),
                isThreeLine: true,
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(SignInRequested(email: account.email));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({
    required this.isLoading,
    required this.errorMessage,
    required this.buttonLabel,
    required this.hintText,
    required this.onSubmit,
  });

  final bool isLoading;
  final String? errorMessage;
  final String buttonLabel;
  final String hintText;
  final ValueChanged<String> onSubmit;

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _emailController = TextEditingController(text: demoEmployeeEmail);

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValid => _emailRegex.hasMatch(_emailController.text.trim());

  void _submit() {
    final email = _emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) return;
    widget.onSubmit(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BossEmailField(
          controller: _emailController,
          hintText: widget.hintText,
          errorText: widget.errorMessage,
          enabled: !widget.isLoading,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        BossPrimaryButton(
          label: widget.buttonLabel,
          isLoading: widget.isLoading,
          onPressed: _isValid && !widget.isLoading ? _submit : null,
        ),
      ],
    );
  }
}
