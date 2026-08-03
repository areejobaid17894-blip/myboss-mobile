import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';

/// RTL-aware back control with a visible label for secondary flows.
class BossBackButton extends StatelessWidget {
  const BossBackButton({
    super.key,
    this.onPressed,
    this.fallbackRoute,
    this.showLabel = true,
  });

  final VoidCallback? onPressed;
  final String? fallbackRoute;
  final bool showLabel;

  static const double preferredWidth = 112;

  void _handleBack(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else if (fallbackRoute != null) {
      context.go(fallbackRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleBack(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8, end: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.orangeDark,
                textDirection: Directionality.of(context),
              ),
              if (showLabel) ...[
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    l10n.back,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.orangeDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard app bar for pushed flows: labeled back + title + language toggle.
class BossFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BossFlowAppBar({
    super.key,
    this.title,
    this.fallbackRoute,
    this.onBack,
    this.actions = const [],
    this.showBack = true,
    this.centerTitle = true,
  });

  final Widget? title;
  final String? fallbackRoute;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showBack;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      leadingWidth: showBack ? BossBackButton.preferredWidth : null,
      automaticallyImplyLeading: false,
      leading: showBack ? BossBackButton(onPressed: onBack, fallbackRoute: fallbackRoute) : null,
      title: title,
      actions: [
        const LanguageToggleButton(),
        ...actions,
      ],
    );
  }
}
