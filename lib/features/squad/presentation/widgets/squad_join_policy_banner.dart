import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_employee_settings_usecase.dart';

String formatSquadJoinDate(String raw, BuildContext context) {
  final parsed = DateTime.tryParse('${raw.trim()}T00:00:00');
  if (parsed == null) return raw;
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).format(parsed);
}

class SquadJoinPolicyBanner extends StatefulWidget {
  const SquadJoinPolicyBanner({super.key, this.settings, this.compact = false});

  final EmployeeSettings? settings;
  final bool compact;

  @override
  State<SquadJoinPolicyBanner> createState() => _SquadJoinPolicyBannerState();
}

class _SquadJoinPolicyBannerState extends State<SquadJoinPolicyBanner> {
  EmployeeSettings? _loaded;

  @override
  void initState() {
    super.initState();
    if (widget.settings == null) {
      _load();
    }
  }

  Future<void> _load() async {
    final response = await getIt<GetEmployeeSettingsUseCase>()();
    if (!mounted) return;
    setState(() => _loaded = response.settings);
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings ?? _loaded;
    if (settings == null || !settings.hasSquadJoinDeadline) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final date = formatSquadJoinDate(settings.squadJoinDeadline, context);
    final email = settings.adminContactEmail;
    final closed = settings.isEmployeeJoinClosed();
    final message = closed
        ? l10n.squadJoinClosedContactAdmin(email)
        : l10n.squadJoinClosesAfter(date);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.compact ? 12 : 14),
      decoration: BoxDecoration(
        color: closed ? const Color(0xFFFFF5F5) : AppColors.orangeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (closed ? AppColors.error : AppColors.orange).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            closed ? Icons.lock_outline_rounded : Icons.event_rounded,
            color: closed ? AppColors.error : AppColors.orangeDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: closed ? AppColors.error : AppColors.grey900,
                    height: 1.45,
                    fontSize: widget.compact ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (closed) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: email));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminEmailCopied)),
                      );
                    },
                    child: Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.orangeDark,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
