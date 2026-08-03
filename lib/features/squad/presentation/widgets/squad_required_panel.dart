import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';

/// Clear call-to-action when a feature needs an active squad.
class SquadRequiredPanel extends StatelessWidget {
  const SquadRequiredPanel({
    super.key,
    required this.l10n,
    this.title,
    this.description,
    this.showFeatureList = true,
    this.hasPendingJoinRequest = false,
    this.pendingSquadName,
    this.onRefresh,
  });

  final AppLocalizations l10n;
  final String? title;
  final String? description;
  final bool showFeatureList;
  final bool hasPendingJoinRequest;
  final String? pendingSquadName;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final panelTitle = hasPendingJoinRequest
        ? l10n.pendingJoinRequestTitle
        : (title ?? l10n.noSquadUnlockTitle);
    final panelDesc = hasPendingJoinRequest
        ? l10n.pendingJoinRequestBody(pendingSquadName ?? '')
        : (description ?? l10n.noSquadUnlockDesc);
    final icon = hasPendingJoinRequest ? Icons.hourglass_top_rounded : Icons.lock_outline_rounded;

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
          if (showFeatureList && !hasPendingJoinRequest) ...[
            const SizedBox(height: 16),
            Text(l10n.noSquadLockedFeaturesTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            _LockedFeatureRow(icon: Icons.chat_rounded, label: l10n.noSquadFeatureChat),
            _LockedFeatureRow(icon: Icons.add_photo_alternate_rounded, label: l10n.noSquadFeatureGalleryUpload),
            _LockedFeatureRow(icon: Icons.assignment_rounded, label: l10n.noSquadFeatureSurveys),
          ],
          const SizedBox(height: 16),
          if (hasPendingJoinRequest)
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(l10n.refresh),
            )
          else
            Row(
              children: [
                Expanded(
                  child: BossPrimaryButton(
                    label: l10n.joinSquad,
                    onPressed: () => context.push('/squad/join'),
                  ),
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
