import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/core/widgets/boss_live_chat_fab.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      BossNavItem(icon: Icons.home_rounded, label: l10n.navHome),
      BossNavItem(icon: Icons.bar_chart_rounded, label: l10n.navReports),
      BossNavItem(icon: Icons.photo_library_rounded, label: l10n.navGallery),
      BossNavItem(icon: Icons.groups_rounded, label: l10n.navMySquad),
      BossNavItem(icon: Icons.person_rounded, label: l10n.navProfile),
    ];

    return Scaffold(
      body: navigationShell,
      floatingActionButton: const BossLiveChatFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BossBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: items,
      ),
    );
  }
}
