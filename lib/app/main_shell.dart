import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/notifications/notification_permission.dart';
import 'package:myboss_mobile/core/notifications/notification_unread_tracker.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/notifications/push_service.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/core/widgets/boss_live_chat_fab.dart';
import 'package:myboss_mobile/features/gallery/domain/usecases/gallery_usecases.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  late final NotificationUnreadTracker _unreadTracker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _unreadTracker = getIt<NotificationUnreadTracker>();
    _unreadTracker.addListener(_onUnreadChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshUnreadCount();
      if (!mounted) return;
      await NotificationPermission.maybePrompt(context);
      final userId = getIt<SessionManager>().currentUser?.id;
      if (userId != null) {
        unawaited(initPushNotifications());
        unawaited(refreshPushRegistration());
        unawaited(registerPushTokenWhenReady(userId));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unreadTracker.removeListener(_onUnreadChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUnreadCount();
      final userId = getIt<SessionManager>().currentUser?.id;
      if (userId != null) {
        unawaited(registerPushTokenWhenReady(userId));
      }
    }
  }

  void _onUnreadChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshUnreadCount() async {
    final session = getIt<SessionManager>();
    final user = session.currentUser;
    if (user == null) return;

    var squad = session.currentSquad;
    squad ??= (await getIt<ResolveUserSquadUseCase>().call(user.id)).squad;

    final listResponse = await getIt<GetNotificationsForUserUseCase>()(
      userId: user.id,
      onboardingCompleted: user.onboardingCompleted,
      openToTravel: user.openToTravel,
      isLeader: squad?.isLeader(user.id) ?? false,
    );

    if (listResponse.failure == null) {
      _unreadTracker.updateFromItems(listResponse.items);
    }
  }

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    if (index != 1) {
      _refreshUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      BossNavItem(icon: Icons.home_rounded, label: l10n.navHome),
      BossNavItem(icon: Icons.notifications_rounded, label: l10n.navNotifications, badgeCount: _unreadTracker.count),
      BossNavItem(icon: Icons.bar_chart_rounded, label: l10n.navReports),
      BossNavItem(icon: Icons.photo_library_rounded, label: l10n.navGallery),
      BossNavItem(icon: Icons.groups_rounded, label: l10n.navMySquad),
      BossNavItem(icon: Icons.person_rounded, label: l10n.navProfile),
    ];

    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: const BossLiveChatFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BossBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTabTap,
        items: items,
      ),
    );
  }
}
