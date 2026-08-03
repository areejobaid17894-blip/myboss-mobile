import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/features/user/domain/usecases/accept_terms_usecase.dart';

/// Blocking terms dialog shown after OTP verification. The user must check the
/// acceptance box and successfully save before continuing.
Future<bool?> showTermsAcceptanceDialog(BuildContext context, {required String userId}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _TermsAcceptanceDialog(userId: userId),
  );
}

class _TermsAcceptanceDialog extends StatefulWidget {
  const _TermsAcceptanceDialog({required this.userId});

  final String userId;

  @override
  State<_TermsAcceptanceDialog> createState() => _TermsAcceptanceDialogState();
}

class _TermsAcceptanceDialogState extends State<_TermsAcceptanceDialog> {
  bool _accepted = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_accepted || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final response = await getIt<AcceptTermsUseCase>().call(id: widget.userId);
    if (!mounted) return;

    if (response.failure != null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = localizedFailureMessage(AppLocalizations.of(context), response.failure!);
      });
      return;
    }

    if (response.profile == null || !response.profile!.hasAcceptedTerms) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = AppLocalizations.of(context).errorGeneric;
      });
      return;
    }

    getIt<SessionManager>().setUser(response.profile!);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.55;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.termsTitle),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight * 0.55),
                child: SingleChildScrollView(
                  child: Text(l10n.termsBody, style: const TextStyle(height: 1.45, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _accepted,
                onChanged: _isSubmitting ? null : (value) => setState(() => _accepted = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  l10n.termsAcceptLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              BossPrimaryButton(
                label: l10n.termsContinue,
                isLoading: _isSubmitting,
                onPressed: _accepted && !_isSubmitting ? _submit : null,
              ),
            ],
          ),
        ),
        actions: const [],
      ),
    );
  }
}
