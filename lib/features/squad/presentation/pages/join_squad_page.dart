import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/error/failure_message_mapper.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/join_squad_cubit.dart';
import 'package:myboss_mobile/features/squad/presentation/squad_formation_navigation.dart';

class JoinSquadPage extends StatelessWidget {
  const JoinSquadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final userId = getIt<SessionManager>().currentUser?.id ?? '';
        return getIt<JoinSquadCubit>()..load(userId: userId);
      },
      child: const _JoinSquadView(),
    );
  }
}

class _JoinSquadView extends StatefulWidget {
  const _JoinSquadView();

  @override
  State<_JoinSquadView> createState() => _JoinSquadViewState();
}

class _JoinSquadViewState extends State<_JoinSquadView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      context.read<JoinSquadCubit>().setSearchQuery(value);
    });
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<JoinSquadCubit>()
      ..setSearchQuery(null)
      ..setGovernorateFilter(null);
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final user = session.currentUser;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.cloud,
      body: SafeArea(
        child: BlocConsumer<JoinSquadCubit, JoinSquadState>(
          listener: (context, state) {
            if (state.joinedRequest != null) {
              context.go('/squad/success', extra: {'mode': 'join'});
            }
            if (state.joinError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizedFailureMessage(l10n, state.joinError!))),
              );
            }
          },
          builder: (context, state) {
            final visibleSquads = state.squads;
            final hasActiveFilters =
                (state.searchQuery ?? '').isNotEmpty || (state.governorateFilter ?? '').isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BossTopBar(onBack: () => popSquadFormationRoute(context)),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: () => context.read<JoinSquadCubit>().load(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(l10n.findYourSquad, style: AppTextStyles.h1),
                                const SizedBox(height: 8),
                                Text(l10n.joinSquadBrowseAllDesc, style: AppTextStyles.muted),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: BossField(
                                        leading: const Text('🔎', style: TextStyle(fontSize: 18)),
                                        child: TextField(
                                          controller: _searchController,
                                          autofocus: true,
                                          textInputAction: TextInputAction.search,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: l10n.searchSquads,
                                            hintStyle: const TextStyle(color: AppColors.grey400),
                                          ),
                                          onChanged: _onSearchChanged,
                                          onSubmitted: _onSearchChanged,
                                        ),
                                      ),
                                    ),
                                    if (hasActiveFilters) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: l10n.clearFilters,
                                        onPressed: _clearFilters,
                                        icon: const Icon(Icons.filter_alt_off_rounded, color: AppColors.orange),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    l10n.filterByGovernorate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _GovernorateFilters(
                                  l10n: l10n,
                                  governorates: state.availableGovernorates,
                                  selected: state.governorateFilter,
                                  onSelected: (value) =>
                                      context.read<JoinSquadCubit>().setGovernorateFilter(value),
                                ),
                                if (!state.isLoading && state.error == null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    hasActiveFilters
                                        ? l10n.squadsFilteredCount(visibleSquads.length, state.allSquads.length)
                                        : l10n.squadsFoundCount(state.allSquads.length),
                                    style: AppTextStyles.small,
                                  ),
                                ],
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),
                        if (state.isLoading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
                          )
                        else if (state.error != null)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: AppErrorView(
                                failure: state.error!,
                                onRetry: () => context.read<JoinSquadCubit>().load(),
                              ),
                            ),
                          )
                        else if (state.allSquads.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l10n.noSquadsAvailable, style: AppTextStyles.muted, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  Text(l10n.joinSquadSearchHint, style: AppTextStyles.small, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        else if (visibleSquads.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l10n.noSquadsFound, style: AppTextStyles.muted, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  TextButton(onPressed: _clearFilters, child: Text(l10n.clearFilters)),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  for (var i = 0; i < visibleSquads.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 10),
                                    _SquadTile(
                                      squad: visibleSquads[i],
                                      isJoining: state.joiningSquadId == visibleSquads[i].id,
                                      isRequestSent: state.pendingSquadId == visibleSquads[i].id,
                                      joinLabel: l10n.join,
                                      requestSentLabel: l10n.requestSent,
                                      fullLabel: l10n.full,
                                      onJoin: user == null || visibleSquads[i].isFull
                                          ? null
                                          : () => context.read<JoinSquadCubit>().join(
                                                squadId: visibleSquads[i].id,
                                                userId: user.id,
                                                firstName: user.firstName,
                                                lastName: user.lastName,
                                                building: user.buildingName,
                                              ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        if (visibleSquads.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                l10n.joinSquadDemoHint,
                                style: AppTextStyles.small,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GovernorateFilters extends StatelessWidget {
  const _GovernorateFilters({
    required this.l10n,
    required this.governorates,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<String> governorates;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.filterAllGovernorates,
            selected: selected == null || selected!.isEmpty,
            onTap: () => onSelected(null),
          ),
          for (final governorate in governorates) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: governorate,
              selected: selected == governorate,
              onTap: () => onSelected(governorate),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.orange,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.black,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      backgroundColor: AppColors.white,
      side: BorderSide(color: selected ? AppColors.orange : AppColors.grey200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _SquadTile extends StatelessWidget {
  const _SquadTile({
    required this.squad,
    required this.isJoining,
    required this.isRequestSent,
    required this.joinLabel,
    required this.requestSentLabel,
    required this.fullLabel,
    required this.onJoin,
  });

  final PublicSquad squad;
  final bool isJoining;
  final bool isRequestSent;
  final String joinLabel;
  final String requestSentLabel;
  final String fullLabel;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    return BossCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cloud,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(squad.badge, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  squad.name,
                  style: AppTextStyles.h2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${squad.squadCode} · ${squad.governorate} · ${squad.memberCount}/${squad.maxMembers}',
                  style: AppTextStyles.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: BossPrimaryButton(
              label: squad.isFull
                  ? fullLabel
                  : isRequestSent
                      ? requestSentLabel
                      : joinLabel,
              compact: true,
              variant: squad.isFull || isRequestSent ? BossButtonVariant.outline : BossButtonVariant.brand,
              isLoading: isJoining,
              onPressed: squad.isFull || isRequestSent ? null : onJoin,
            ),
          ),
        ],
      ),
    );
  }
}
