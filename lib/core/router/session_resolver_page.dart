import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/router/post_auth_resolver.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_logo.dart';

/// Transient page shown right after authentication while we determine
/// whether the user needs onboarding, squad formation, or can go straight
/// to the home dashboard.
class SessionResolverPage extends StatefulWidget {
  const SessionResolverPage({super.key, required this.userId});

  final String userId;

  @override
  State<SessionResolverPage> createState() => _SessionResolverPageState();
}

class _SessionResolverPageState extends State<SessionResolverPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    var userId = widget.userId.trim();
    if (userId.isEmpty) {
      userId = (await getIt<SecureStorageService>().getUserId())?.trim() ?? '';
    }

    if (userId.isEmpty) {
      if (!mounted) return;
      context.go('/sign-in');
      return;
    }

    try {
      final route = await const PostAuthResolver()
          .resolve(userId)
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      context.go(route);
      unawaited(registerPushTokenWhenReady(userId));
    } catch (_) {
      if (!mounted) return;
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BossLogo(showTagline: false),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}
