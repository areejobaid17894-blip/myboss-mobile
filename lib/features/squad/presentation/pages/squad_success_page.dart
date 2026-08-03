import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';

class SquadSuccessPage extends StatelessWidget {
  const SquadSuccessPage({super.key, required this.mode, this.squad});

  final String mode;
  final Squad? squad;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCreate = mode == 'create';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const Spacer(),
              Transform.rotate(
                angle: -0.1,
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [BoxShadow(color: Color(0x59FF7900), blurRadius: 30, offset: Offset(0, 14))],
                  ),
                  alignment: Alignment.center,
                  child: Text(isCreate ? (squad?.badge ?? '🎉') : '🤝', style: const TextStyle(fontSize: 52)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isCreate ? l10n.squadCreated : l10n.requestSent,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isCreate ? l10n.squadCreatedBodyNamed(squad?.name ?? '', squad?.squadCode ?? '') : l10n.requestSentBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 24),
              BossCard(
                child: Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.destinationIncomingTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(l10n.destinationIncomingBody, style: AppTextStyles.small),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BossPrimaryButton(
                label: isCreate ? l10n.takeMeHome : l10n.takeMeHome,
                onPressed: () => context.go('/home'),
              ),
              if (!isCreate) ...[
                const SizedBox(height: 12),
                BossPrimaryButton(
                  label: l10n.continueWithoutSquad,
                  variant: BossButtonVariant.outline,
                  onPressed: () {
                    getIt<SessionManager>().markConfirmedNoSquad();
                    context.go('/home');
                  },
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
