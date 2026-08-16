import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_employee_settings_usecase.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_join_policy_banner.dart';

/// Clear call-to-action when a feature needs an active squad.
class SquadRequiredPanel extends StatefulWidget {
  const SquadRequiredPanel({
    super.key,
    required this.l10n,
    this.title,
    this.description,
    this.showFeatureList = true,
    this.hasPendingJoinRequest = false,
    this.isPendingInvite = false,
    this.pendingSquadName,
    this.onRefresh,
  });

  final AppLocalizations l10n;
  final String? title;
  final String? description;
  final bool showFeatureList;
  final bool hasPendingJoinRequest;
  final bool isPendingInvite;
  final String? pendingSquadName;
  final VoidCallback? onRefresh;

  @override
  State<SquadRequiredPanel> createState() => _SquadRequiredPanelState();
}

class _SquadRequiredPanelState extends State<SquadRequiredPanel> {
  EmployeeSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final response = await getIt<GetEmployeeSettingsUseCase>()();
    if (!mounted) return;
    setState(() => _settings = response.settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final closed = _settings?.isEmployeeJoinClosed() ?? false;
    final panelTitle = widget.isPendingInvite
        ? l10n.pendingInviteTitle
        : widget.hasPendingJoinRequest
            ? l10n.pendingJoinRequestTitle
            : (widget.title ?? l10n.noSquadUnlockTitle);
    final panelDesc = widget.isPendingInvite
        ? l10n.pendingInviteBody(widget.pendingSquadName ?? '')
        : widget.hasPendingJoinRequest
            ? l10n.pendingJoinRequestBody(widget.pendingSquadName ?? '')
            : (widget.description ?? l10n.noSquadUnlockDesc);
    final icon = widget.hasPendingJoinRequest ? Icons.hourglass_top_rounded : Icons.lock_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(panelTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.black)),
                    const SizedBox(height: 6),
                    Text(panelDesc, style: const TextStyle(color: AppColors.grey900, height: 1.45, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          if (widget.showFeatureList && !widget.hasPendingJoinRequest) ...[
            const SizedBox(height: 16),
            Text(l10n.noSquadLockedFeaturesTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            _LockedFeatureRow(icon: Icons.chat_rounded, label: l10n.noSquadFeatureChat),
            _LockedFeatureRow(icon: Icons.add_photo_alternate_rounded, label: l10n.noSquadFeatureGalleryUpload),
            _LockedFeatureRow(icon: Icons.assignment_rounded, label: l10n.noSquadFeatureSurveys),
          ],
          const SizedBox(height: 16),
          SquadJoinPolicyBanner(settings: _settings, compact: true),
          const SizedBox(height: 12),
          if (widget.isPendingInvite)
            BossPrimaryButton(
              label: l10n.goToMySquad,
              onPressed: () => context.push('/my-squad'),
            )
          else if (widget.hasPendingJoinRequest)
            OutlinedButton(
              onPressed: widget.onRefresh,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(l10n.refresh),
            )
          else if (!closed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BossPrimaryButton(
                  label: l10n.createSquad,
                  onPressed: () => context.push('/squad/create'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.push('/squad/join'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(l10n.joinSquad),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LockedFeatureRow extends StatelessWidget {
  const _LockedFeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey600),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.grey600, fontSize: 13))),
          const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.grey400),
        ],
      ),
    );
  }
}

/// Compact inline hint for profile link tiles gated by squad membership.
class SquadLockedFeatureTile extends StatelessWidget {
  const SquadLockedFeatureTile({
    super.key,
    required this.icon,
    required this.label,
    required this.lockedHint,
    required this.onJoin,
  });

  final IconData icon;
  final String label;
  final String lockedHint;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onJoin,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey600)),
                  const SizedBox(height: 2),
                  Text(lockedHint, style: const TextStyle(color: AppColors.grey600, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.lock_outline_rounded, color: AppColors.grey400, size: 18),
          ],
        ),
      ),
    );
  }
}
