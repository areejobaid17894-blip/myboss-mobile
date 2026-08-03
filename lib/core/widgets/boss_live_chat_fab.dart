import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

/// Floating live-chat entry point on main tab screens (squad members only).
class BossLiveChatFab extends StatelessWidget {
  const BossLiveChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FloatingActionButton.extended(
      backgroundColor: AppColors.orange,
      onPressed: () => context.push('/chat'),
      icon: const Icon(Icons.chat_rounded, color: AppColors.white),
      label: Text(l10n.liveChat, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
    );
  }
}
