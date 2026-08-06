import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/notifications/push_registration_state.dart';
import 'package:myboss_mobile/core/notifications/push_service.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';

/// Demo-only panel to inspect FCM token registration on Profile.
class DemoPushStatusPanel extends StatefulWidget {
  const DemoPushStatusPanel({super.key});

  static const enabled = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  @override
  State<DemoPushStatusPanel> createState() => _DemoPushStatusPanelState();
}

class _DemoPushStatusPanelState extends State<DemoPushStatusPanel> {
  String? _token;
  String? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshToken();
  }

  Future<void> _refreshToken() async {
    final token = await getIt<PushRegistrationService>().currentToken();
    final state = PushRegistrationState.instance;
    if (!mounted) return;
    setState(() {
      _token = token;
      if (state.lastAttemptSucceeded) {
        _status = 'Registered with backend at ${state.lastRegisteredAt?.toIso8601String() ?? 'now'}';
      } else if (state.lastError != null) {
        _status = state.lastError;
      } else if (token == null || token.isEmpty) {
        _status = 'No local FCM token — allow notifications and tap Register push';
      } else {
        _status = 'Token stored locally, not confirmed on backend yet';
      }
    });
  }

  Future<void> _registerNow() async {
    final userId = getIt<SessionManager>().currentUser?.id;
    if (userId == null) {
      setState(() => _status = 'Not logged in');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Registering… (may take up to 2 minutes on first launch)';
    });

    final ok = await registerPushTokenWhenReady(userId);
    await _refreshToken();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok && PushRegistrationState.instance.lastError != null) {
        _status = PushRegistrationState.instance.lastError;
      } else if (ok) {
        _status = 'Registered with backend';
      }
    });
  }

  Future<void> _copyToken() async {
    final token = _token;
    if (token == null || token.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FCM token copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!DemoPushStatusPanel.enabled || !PushService.pushEnabled) {
      return const SizedBox.shrink();
    }

    final preview = _token == null || _token!.isEmpty
        ? '—'
        : '${_token!.substring(0, _token!.length.clamp(0, 32))}…';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Push notifications (demo)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            _status ?? 'Checking…',
            style: TextStyle(
              color: PushRegistrationState.instance.lastAttemptSucceeded
                  ? AppColors.grey600
                  : AppColors.error,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            preview,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BossPrimaryButton(
                  label: _busy ? 'Working…' : 'Register push',
                  isLoading: _busy,
                  onPressed: _busy ? null : _registerNow,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy token',
                onPressed: _token == null || _token!.isEmpty ? null : _copyToken,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
