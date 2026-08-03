import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';

class VestSizePage extends StatefulWidget {
  const VestSizePage({super.key});

  @override
  State<VestSizePage> createState() => _VestSizePageState();
}

class _VestSizePageState extends State<VestSizePage> {
  String? _selectedSize;

  static const _rows = [
    ['S', 'M', 'L'],
    ['XL', 'XXL', '3XL'],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _skipIfAlreadyComplete());
  }

  void _skipIfAlreadyComplete() {
    final profile = getIt<SessionManager>().currentUser;
    if (profile == null || !mounted) return;

    if (OnboardingNavigation.hasVest(profile)) {
      context.go('/onboarding/building', extra: profile.vestSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: BossScreenPad(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BossStepBar(currentStep: 1),
            const SizedBox(height: 20),
            BossStepTag(label: l10n.step1Tag),
            const SizedBox(height: 10),
            Text(l10n.vestSizeTitle, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(l10n.vestSizeSubtitle, style: AppTextStyles.muted),
            const SizedBox(height: 20),
            for (final row in _rows) ...[
              BossChipRow(
                options: row,
                selected: _selectedSize,
                onSelected: (size) => setState(() => _selectedSize = size),
              ),
              const SizedBox(height: 10),
            ],
            BossCard(
              child: Row(
                children: [
                  const Text('🦺', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.vestSizeHint, style: AppTextStyles.small)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            BossPrimaryButton(
              label: l10n.continueLabel,
              onPressed: _selectedSize == null ? null : () => context.push('/onboarding/building', extra: _selectedSize),
            ),
          ],
        ),
      ),
    );
  }
}
