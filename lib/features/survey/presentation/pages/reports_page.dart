import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/features/squad/domain/squad_access.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_required_panel.dart';
import 'package:myboss_mobile/features/survey/presentation/cubit/reports_cubit.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _checkingAccess = true;
  bool _hasSquadAccess = false;

  @override
  void initState() {
    super.initState();
    _resolveAccess();
  }

  Future<void> _resolveAccess() async {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';

    if (userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _checkingAccess = false;
        _hasSquadAccess = false;
      });
      return;
    }

    if (hasActiveSquad(session)) {
      if (!mounted) return;
      setState(() {
        _checkingAccess = false;
        _hasSquadAccess = true;
      });
      return;
    }

    final statusResponse = await getIt<GetJoinStatusUseCase>().call(userId);
    if (!mounted) return;
    setState(() {
      _checkingAccess = false;
      _hasSquadAccess = statusResponse.status?.inSquad ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_checkingAccess) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportsTitle), centerTitle: false),
        body: const Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );
    }

    if (!_hasSquadAccess) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportsTitle), centerTitle: false),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SquadRequiredPanel(
            l10n: l10n,
            title: l10n.reportsSquadRequiredTitle,
            description: l10n.reportsSquadRequiredDesc,
            showFeatureList: false,
          ),
        ),
      );
    }

    return const _ReportsContent();
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final squadId = activeSquadId(session);
    final governorate = session.currentUser?.governorate;
    final isAdmin = session.currentUser?.role == 'admin';
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) {
        final cubit = getIt<ReportsCubit>();
        if (squadId != null && squadId.isNotEmpty) {
          cubit.load('squad', id: squadId);
        }
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.reportsTitle), centerTitle: false),
        body: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            void retry() {
              final cubit = context.read<ReportsCubit>();
              final scope = cubit.state.scope;
              if (scope == 'squad' && squadId != null) {
                cubit.load('squad', id: squadId);
              } else if (scope == 'governorate' && governorate != null) {
                cubit.load('governorate', id: governorate);
              } else {
                cubit.load(scope);
              }
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _ScopeChip(
                        label: l10n.scopeMySquad,
                        selected: state.scope == 'squad',
                        onTap: squadId == null ? null : () => context.read<ReportsCubit>().load('squad', id: squadId),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        _ScopeChip(
                          label: l10n.scopeCompany,
                          selected: state.scope == 'company',
                          onTap: () => context.read<ReportsCubit>().load('company'),
                        ),
                        const SizedBox(width: 8),
                        _ScopeChip(
                          label: l10n.scopeMyGovernorate,
                          selected: state.scope == 'governorate',
                          onTap: governorate == null
                              ? null
                              : () => context.read<ReportsCubit>().load('governorate', id: governorate),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                      : state.error != null
                          ? AppErrorView(
                              failure: state.error!,
                              onRetry: retry,
                            )
                          : state.report == null
                              ? const SizedBox.shrink()
                              : _ReportBody(report: state.report!, l10n: l10n),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: AppColors.orange,
      labelStyle: TextStyle(color: selected ? AppColors.white : AppColors.black, fontWeight: FontWeight.w600),
      backgroundColor: AppColors.grey100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.l10n});

  final dynamic report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.totalResponses,
                value: '${report.totalResponses}',
                icon: Icons.fact_check_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: l10n.avgSatisfaction,
                value: report.avgSatisfaction.toStringAsFixed(1),
                icon: Icons.star_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: l10n.surveysPerHour,
          value: '${report.surveysPerHour}',
          icon: Icons.speed_rounded,
          fullWidth: true,
        ),
        const SizedBox(height: 24),
        Text(l10n.topPriorities, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black)),
        const SizedBox(height: 12),
        if (report.topPriorities.isEmpty)
          Text(l10n.noPriorityData, style: const TextStyle(color: AppColors.grey600))
        else
          ...List.generate(report.topPriorities.length, (index) {
            final p = report.topPriorities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.orangeLight,
                    child: Text('${index + 1}', style: const TextStyle(color: AppColors.orangeDark, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (p.percentage as num) / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.grey200,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${p.count}', style: const TextStyle(color: AppColors.grey600)),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, this.fullWidth = false});

  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orange),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.black)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grey600, fontSize: 13)),
        ],
      ),
    );
  }
}
