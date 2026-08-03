import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/auth/sign_out_helper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

/// Prominent full-width logout control.
class BossLogOutButton extends StatelessWidget {
  const BossLogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => confirmAndSignOut(context),
        icon: const Icon(Icons.logout_rounded, size: 22),
        label: Text(
          l10n.logOut,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

/// Compact logout action for app bars.
class BossLogOutAppBarAction extends StatelessWidget {
  const BossLogOutAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: TextButton.icon(
        onPressed: () => confirmAndSignOut(context),
        icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
        label: Text(
          l10n.logOut,
          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
