import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/auth/session_lifecycle.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';

Future<void> confirmAndSignOut(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.logOutConfirmTitle),
      content: Text(l10n.logOutConfirmMessage),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.logOutConfirmNo)),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.logOutConfirmYes)),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  await endUserSession();
}
