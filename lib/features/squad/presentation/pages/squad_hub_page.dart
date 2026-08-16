import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/squad_hub_cubit.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_join_policy_banner.dart';

class SquadHubPage extends StatelessWidget {
  const SquadHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';

    return BlocProvider(
      create: (_) => getIt<SquadHubCubit>()..load(userId: userId),
      child: const _SquadHubView(),
    );
  }
}

class _SquadHubView extends StatelessWidget {
  const _SquadHubView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<SquadHubCubit, SquadHubState>(
      listener: (context, state) {
        if (state is SquadHubLoaded && state.isInSquad) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: BossScreenPad(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BossStepBar(currentStep: 3),
              const SizedBox(height: 20),
              BossStepTag(label: l10n.step3Tag),
              const SizedBox(height: 10),
              Text(l10n.formYourSquad, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(l10n.formYourSquadDesc, style: AppTextStyles.muted),
              const SizedBox(height: 16),
              const SquadJoinPolicyBanner(),
              const SizedBox(height: 16),
              BlocBuilder<SquadHubCubit, SquadHubState>(
                builder: (context, state) {
                  if (state is SquadHubLoaded) {
                    final formed = state.stats.totalSquads;
                    final max = state.stats.maxSquads;
                    final progress = max > 0 ? formed / max : 0.0;
                    final pending = state.hasPendingJoinRequest;
                    final closed = state.employeeJoinClosed;
                    final blockActions = pending || closed;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (pending) ...[
                          BossCard(
                            backgroundColor: AppColors.orangeLight,
                            borderColor: AppColors.orangeBorder,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.isPendingInvite ? l10n.pendingInviteTitle : l10n.pendingJoinRequestTitle,
                                  style: AppTextStyles.h2,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.isPendingInvite
                                      ? l10n.pendingInviteBody(state.joinStatus?.squadName ?? '')
                                      : l10n.pendingJoinRequestBody(state.joinStatus?.squadName ?? ''),
                                  style: AppTextStyles.small,
                                ),
                                if (state.isPendingInvite) ...[
                                  const SizedBox(height: 12),
                                  if (state.error != null) ...[
                                    AppErrorView(failure: state.error!),
                                    const SizedBox(height: 8),
                                  ],
                                  if (!closed)
                                    BossPrimaryButton(
                                      label: l10n.acceptInvite,
                                      isLoading: state.isRespondingInvite,
                                      onPressed: state.isRespondingInvite
                                          ? null
                                          : () => context.read<SquadHubCubit>().respondToInvite(accept: true),
                                    ),
                                  const SizedBox(height: 8),
                                  BossPrimaryButton(
                                    label: l10n.rejectInvite,
                                    variant: BossButtonVariant.outline,
                                    onPressed: state.isRespondingInvite
                                        ? null
                                        : () => context.read<SquadHubCubit>().respondToInvite(accept: false),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (!closed) ...[
                          BossCard(
                            borderColor: AppColors.orange,
                            borderWidth: 2,
                            onTap: blockActions ? null : () => context.push('/squad/create'),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.createSquad, style: AppTextStyles.h2),
                                      const SizedBox(height: 6),
                                      Text(l10n.createSquadDesc, style: AppTextStyles.muted),
                                    ],
                                  ),
                                ),
                                const Text('🚩', style: TextStyle(fontSize: 22)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          BossCard(
                            onTap: blockActions ? null : () => context.push('/squad/join'),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.joinSquad, style: AppTextStyles.h2),
                                      const SizedBox(height: 6),
                                      Text(l10n.joinSquadDesc, style: AppTextStyles.muted),
                                    ],
                                  ),
                                ),
                                const Text('🤝', style: TextStyle(fontSize: 22)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        BossCard(
                          backgroundColor: AppColors.orangeLight,
                          borderColor: AppColors.orangeBorder,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.squadsFormedProgress(formed, max),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              BossProgressBar(progress: progress, color: AppColors.orange),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        BossPrimaryButton(
                          label: l10n.continueWithoutSquad,
                          variant: BossButtonVariant.outline,
                          onPressed: () {
                            getIt<SessionManager>().markConfirmedNoSquad();
                            context.go('/home');
                          },
                        ),
                      ],
                    );
                  }
                  if (state is SquadHubError) {
                    return AppErrorView(
                      failure: state.failure,
                      onRetry: () {
                        final userId = getIt<SessionManager>().currentUser?.id ?? '';
                        context.read<SquadHubCubit>().load(userId: userId);
                      },
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
