import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/features/config/domain/entities/building.dart';
import 'package:myboss_mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class BuildingMobilityPage extends StatelessWidget {
  const BuildingMobilityPage({super.key, required this.vestSize});

  final String vestSize;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>()..loadBuildings(),
      child: _BuildingMobilityView(vestSize: vestSize),
    );
  }
}

class _BuildingMobilityView extends StatefulWidget {
  const _BuildingMobilityView({required this.vestSize});

  final String vestSize;

  @override
  State<_BuildingMobilityView> createState() => _BuildingMobilityViewState();
}

class _BuildingMobilityViewState extends State<_BuildingMobilityView> {
  Building? _selectedBuilding;
  bool _openToTravel = false;
  final Set<String> _preferredGovernorates = {};

  static const _allGovernorates = [
    'Amman', 'Irbid', 'Zarqa', 'Aqaba', 'Karak', 'Mafraq', "Ma'an", 'Balqa', 'Madaba', 'Jerash', 'Ajloun', 'Tafilah',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _skipIfAlreadyComplete());
  }

  void _skipIfAlreadyComplete() {
    final profile = getIt<SessionManager>().currentUser;
    if (profile == null || !mounted) return;

    if (OnboardingNavigation.isComplete(profile)) {
      context.go('/squad/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.updatedProfile != null) {
            session.setUser(state.updatedProfile!);
            context.go('/squad/hub');
          }
        },
        builder: (context, state) {
          return BossScreenPad(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BossTopBar(onBack: () => context.go('/onboarding/vest-size')),
                const BossStepBar(currentStep: 2),
                const SizedBox(height: 20),
                BossStepTag(label: l10n.step2Tag),
                const SizedBox(height: 10),
                Text(l10n.buildingTitle, style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(l10n.buildingSubtitle, style: AppTextStyles.muted),
                const SizedBox(height: 18),
                if (state.isLoadingBuildings)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
                  )
                else if (state.buildingsError != null)
                  AppErrorView(
                    failure: state.buildingsError!,
                    onRetry: () => context.read<OnboardingCubit>().loadBuildings(),
                  )
                else ...[
                  BossField(
                    leading: const Text('🏢', style: TextStyle(fontSize: 18)),
                    label: l10n.selectBuilding,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Building>(
                        value: _selectedBuilding,
                        isExpanded: true,
                        hint: Text(l10n.selectBuilding, style: AppTextStyles.muted),
                        items: state.buildings
                            .map((b) => DropdownMenuItem(value: b, child: Text(b.name, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (b) => setState(() => _selectedBuilding = b),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BossField(
                    leading: const Text('🔒', style: TextStyle(fontSize: 18)),
                    label: l10n.governorate,
                    backgroundColor: AppColors.grey100,
                    enabled: false,
                    child: Text(_selectedBuilding?.governorate ?? '—'),
                  ),
                  const SizedBox(height: 18),
                  BossCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BossToggle(value: _openToTravel, onChanged: (v) => setState(() => _openToTravel = v)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.openToTravel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(l10n.openToTravelDesc, style: AppTextStyles.small),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_openToTravel) ...[
                    const SizedBox(height: 10),
                    BossCard(
                      borderColor: AppColors.success,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.travelPrefTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          BossWrapChips(
                            options: _allGovernorates.where((g) => g != _selectedBuilding?.governorate).toList(),
                            selected: _preferredGovernorates,
                            onToggle: (g) => setState(() {
                              if (_preferredGovernorates.contains(g)) {
                                _preferredGovernorates.remove(g);
                              } else {
                                _preferredGovernorates.add(g);
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 18),
                if (state.submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      localizedFailureMessage(l10n, state.submitError!),
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                BossPrimaryButton(
                  label: l10n.continueLabel,
                  isLoading: state.isSubmitting,
                  onPressed: _selectedBuilding == null || session.currentUser == null
                      ? null
                      : () => context.read<OnboardingCubit>().submit(
                            userId: session.currentUser!.id,
                            vestSize: widget.vestSize,
                            buildingId: _selectedBuilding!.id,
                            buildingName: _selectedBuilding!.name,
                            governorate: _selectedBuilding!.governorate,
                            openToTravel: _openToTravel,
                            preferredGovernorates: _preferredGovernorates.toList(),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
