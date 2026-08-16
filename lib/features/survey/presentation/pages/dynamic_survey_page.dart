import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_back_button.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/features/survey/presentation/cubit/dynamic_survey_cubit.dart';
import 'package:myboss_mobile/features/survey/presentation/widgets/dynamic_question_widget.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_access_gate.dart';

class DynamicSurveyPage extends StatelessWidget {
  const DynamicSurveyPage({super.key, required this.segment});

  final String segment;

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';
    final l10n = AppLocalizations.of(context);

    return SquadAccessGate(
      userId: userId,
      builder: (context, squad) => BlocProvider(
        create: (_) => getIt<DynamicSurveyCubit>()
          ..load(
            segment,
            userId: userId,
            squadId: squad.id,
            governorate: session.currentUser?.governorate ?? '',
          ),
        child: _DynamicSurveyShell(
          segment: segment,
          squadId: squad.id,
          title: segment == 'employee' ? l10n.employeeFeedback : l10n.customerSurvey,
        ),
      ),
    );
  }
}

class _DynamicSurveyShell extends StatelessWidget {
  const _DynamicSurveyShell({
    required this.segment,
    required this.squadId,
    required this.title,
  });

  final String segment;
  final String squadId;
  final String title;

  Future<void> _confirmLeave(BuildContext context) async {
    final cubit = context.read<DynamicSurveyCubit>();
    await cubit.saveDraftOnClose();
    if (!context.mounted) return;
    final state = cubit.state;
    if (!state.hasAnswers || state.submitSuccess || state.savedOffline) {
      _leave(context);
      return;
    }

    final l10n = AppLocalizations.of(context);
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.surveyCloseConfirmTitle),
        content: Text(l10n.surveyCloseConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.surveyStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.surveyLeave),
          ),
        ],
      ),
    );

    if (shouldLeave == true && context.mounted) {
      await cubit.saveDraftOnClose();
      if (context.mounted) _leave(context);
    }
  }

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmLeave(context);
      },
      child: Scaffold(
        appBar: BossFlowAppBar(
          title: Text(title),
          fallbackRoute: '/home',
          onBack: () => _confirmLeave(context),
        ),
        body: _DynamicSurveyView(segment: segment, squadId: squadId),
      ),
    );
  }
}

class _DynamicSurveyView extends StatelessWidget {
  const _DynamicSurveyView({required this.segment, required this.squadId});

  final String segment;
  final String squadId;

  Future<void> _confirmAndSubmit(BuildContext context) async {
    final cubit = context.read<DynamicSurveyCubit>();
    if (!cubit.prepareSubmit()) return;

    final l10n = AppLocalizations.of(context);
    final session = getIt<SessionManager>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.surveyFinishConfirmTitle),
        content: Text(l10n.surveyFinishConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.surveyStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.submit),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await cubit.submit(
          squadId: squadId,
          userId: session.currentUser?.id ?? '',
          governorate: session.currentUser?.governorate ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: BlocConsumer<DynamicSurveyCubit, DynamicSurveyState>(
        listenWhen: (previous, current) =>
            (!previous.submitSuccess && current.submitSuccess) ||
            (!previous.savedOffline && current.savedOffline),
        listener: (context, state) {
          if (state.submitSuccess) {
            _showSuccessDialog(context, l10n);
          } else if (state.savedOffline) {
            _showOfflineSavedDialog(context, l10n);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          if (state.error != null) {
            final session = getIt<SessionManager>();
            return AppErrorView(
              failure: state.error!,
              onRetry: () => context.read<DynamicSurveyCubit>().load(
                    segment,
                    userId: session.currentUser?.id ?? '',
                    squadId: squadId,
                    governorate: session.currentUser?.governorate ?? '',
                  ),
            );
          }
          if (state.orderedQuestions.isEmpty) {
            return Center(child: Text(l10n.noSurveyQuestions));
          }

          final question = state.currentQuestion!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 8,
                    backgroundColor: AppColors.grey200,
                    color: AppColors.orange,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.questionProgress(state.currentIndex + 1, state.orderedQuestions.length),
                    style: const TextStyle(color: AppColors.grey600, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: DynamicQuestionWidget(
                    key: ValueKey(question.id),
                    question: question,
                    value: state.answers[question.id],
                    errorText: _fieldErrorMessage(l10n, state.fieldErrorCode),
                    onChanged: (value) => context.read<DynamicSurveyCubit>().setAnswer(question.id, value),
                  ),
                ),
              ),
              if (state.submitError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    localizedFailureMessage(l10n, state.submitError!),
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  children: [
                    if (!state.isFirstQuestion)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.read<DynamicSurveyCubit>().back(),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                          child: Text(l10n.back),
                        ),
                      ),
                    if (!state.isFirstQuestion) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: BossPrimaryButton(
                        label: state.isLastQuestion ? l10n.submit : l10n.next,
                        icon: state.isLastQuestion ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        isLoading: state.isSubmitting,
                        onPressed: !state.canGoNext
                            ? null
                            : () {
                                if (state.isLastQuestion) {
                                  _confirmAndSubmit(context);
                                } else {
                                  context.read<DynamicSurveyCubit>().next();
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String? _fieldErrorMessage(AppLocalizations l10n, String? code) {
    if (code == null) return null;
    return switch (code) {
      'CONSENT_NAME_REQUIRED' => l10n.errorConsentNameRequired,
      'CONSENT_NATIONAL_ID_INVALID' => l10n.errorInvalidNationalId,
      'CONSENT_PHONE_INVALID' => l10n.errorInvalidPhone,
      'CONSENT_SIGNATURE_REQUIRED' => l10n.errorConsentSignatureRequired,
      _ => l10n.errorValidation,
    };
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
            const SizedBox(height: 12),
            Text(l10n.surveySuccessTitle),
          ],
        ),
        content: Text(l10n.surveySuccessBody, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: BossPrimaryButton(
              label: l10n.done,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.pop(true);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOfflineSavedDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.surveyOfflineSavedTitle),
        content: Text(l10n.surveyOfflineSavedBody, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: BossPrimaryButton(
              label: l10n.done,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (context.canPop()) {
                  context.pop(false);
                } else {
                  context.go('/home');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
