import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/notifications/notification_unread_tracker.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:myboss_mobile/features/squad/presentation/widgets/squad_required_panel.dart';
import 'package:myboss_mobile/features/survey/data/survey_draft_store.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final userId = session.currentUser?.id ?? '';

    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..load(userId),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _openSurvey(BuildContext context, String segment, String userId) async {
    await context.push('/survey/$segment');
    if (!context.mounted) return;
    await context.read<HomeCubit>().load(userId);
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final user = session.currentUser;
    final userId = user?.id ?? '';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: const [LanguageToggleButton()],
      ),
      body: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: () async => context.read<HomeCubit>().load(userId),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final surveysLocked = state.surveyTargetReached;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.homeWelcome(user?.firstName ?? ''),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.black),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.grey600)),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: getIt<NotificationUnreadTracker>(),
                  builder: (context, _) {
                    final unreadCount = getIt<NotificationUnreadTracker>().count;
                    if (unreadCount <= 0) return const SizedBox.shrink();
                    return Column(
                      children: [
                        _NotificationBanner(
                          count: unreadCount,
                          onTap: () => context.go('/notifications'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                if (state.isLoading && !state.hasActiveSquad && state.surveys.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
                  )
                else ...[
                  if (state.squadLoadFailed && state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AppErrorView(
                        failure: state.error!,
                        onRetry: () => context.read<HomeCubit>().load(userId),
                      ),
                    ),
                  if (state.showNoSquadExperience) ...[
                    if (state.hasPendingJoinRequest)
                      SquadRequiredPanel(
                        l10n: l10n,
                        hasPendingJoinRequest: true,
                        isPendingInvite: state.joinStatus?.isPendingInvite ?? false,
                        pendingSquadName: state.joinStatus?.squadName,
                        onRefresh: () => context.read<HomeCubit>().load(userId),
                        onCancelJoinRequest: () => context.read<HomeCubit>().load(userId),
                        showFeatureList: false,
                      )
                    else
                      SquadRequiredPanel(l10n: l10n),
                    const SizedBox(height: 20),
                    if (state.pendingOffline.isNotEmpty) ...[
                      _OfflineSurveysSection(
                        items: state.pendingOffline,
                        surveys: state.surveys,
                        l10n: l10n,
                        onOpen: (segment) => _openSurvey(context, segment, userId),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _LockedServicesSection(surveys: state.surveys, l10n: l10n),
                  ] else if (state.hasActiveSquad) ...[
                    if (state.surveys.isNotEmpty)
                      BossCard(
                        backgroundColor: AppColors.ink,
                        borderColor: AppColors.ink,
                        onTap: surveysLocked
                            ? null
                            : () => _openSurvey(context, state.surveys.first.segment, userId),
                        padding: const EdgeInsets.all(18),
                        child: Opacity(
                          opacity: surveysLocked ? 0.55 : 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surveysLocked ? l10n.surveyTargetReachedTitle : l10n.addCustomer,
                                      style: AppTextStyles.h2.copyWith(color: AppColors.orange),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      surveysLocked ? l10n.surveyTargetReachedBody : l10n.addCustomerDesc,
                                      style: AppTextStyles.small.copyWith(color: const Color(0xFFBBBBBB)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Text(surveysLocked ? '✅' : '📋', style: const TextStyle(fontSize: 22)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _ProgressCard(
                      squadName: state.squad!.name,
                      badge: state.squad!.badge,
                      progress: state.progress,
                      progressLabel: l10n.surveyProgress,
                      targetReachedHint: l10n.surveyTargetReachedHint,
                    ),
                    const SizedBox(height: 20),
                    if (state.pendingOffline.isNotEmpty) ...[
                      _OfflineSurveysSection(
                        items: state.pendingOffline,
                        surveys: state.surveys,
                        l10n: l10n,
                        onOpen: (segment) => _openSurvey(context, segment, userId),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (state.report != null)
                      _RankingsCard(
                        report: state.report!,
                        title: l10n.governorateInsights,
                        responsesLabel: l10n.responses,
                        satisfactionLabel: l10n.avgSatisfaction,
                        perHourLabel: l10n.perHour,
                      ),
                    const SizedBox(height: 20),
                    if (state.surveys.isNotEmpty)
                      _ServiceTemplatesSection(
                        surveys: state.surveys,
                        l10n: l10n,
                        locked: surveysLocked,
                        pendingSegments: {
                          for (final item in state.pendingOffline) item.segment,
                        },
                        onOpen: (segment) => _openSurvey(context, segment, userId),
                      ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServiceTemplatesSection extends StatefulWidget {
  const _ServiceTemplatesSection({
    required this.surveys,
    required this.l10n,
    this.locked = false,
    this.pendingSegments = const {},
    this.onOpen,
  });

  final List<DynamicSurvey> surveys;
  final AppLocalizations l10n;
  final bool locked;
  final Set<String> pendingSegments;
  final Future<void> Function(String segment)? onOpen;

  @override
  State<_ServiceTemplatesSection> createState() => _ServiceTemplatesSectionState();
}

class _ServiceTemplatesSectionState extends State<_ServiceTemplatesSection> {
  static const _initialVisibleCount = 2;
  bool _expanded = false;

  String _segmentLabel(String segment) {
    switch (segment) {
      case 'business':
        return widget.l10n.segmentBusiness;
      case 'employee':
        return widget.l10n.segmentEmployee;
      default:
        return widget.l10n.segmentConsumer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCount = _expanded ? widget.surveys.length : _initialVisibleCount.clamp(0, widget.surveys.length);
    final visibleSurveys = widget.surveys.take(visibleCount).toList();
    final hasMore = widget.surveys.length > _initialVisibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.serviceTemplates,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.black),
        ),
        const SizedBox(height: 6),
        Text(
          widget.l10n.serviceTemplatesDesc,
          style: const TextStyle(color: AppColors.grey600, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 16),
        ...visibleSurveys.map(
          (survey) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SurveyTemplateTile(
              survey: survey,
              segmentLabel: _segmentLabel(survey.segment),
              locked: widget.locked,
              pendingOffline: widget.pendingSegments.contains(survey.segment),
              onOpen: widget.onOpen == null ? null : () => widget.onOpen!(survey.segment),
            ),
          ),
        ),
        if (hasMore)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
            label: Text(
              _expanded
                  ? widget.l10n.showLess
                  : widget.l10n.showMore(widget.surveys.length - _initialVisibleCount),
            ),
          ),
      ],
    );
  }
}

class _OfflineSurveysSection extends StatelessWidget {
  const _OfflineSurveysSection({
    required this.items,
    required this.surveys,
    required this.l10n,
    required this.onOpen,
  });

  final List<SurveyPendingSubmission> items;
  final List<DynamicSurvey> surveys;
  final AppLocalizations l10n;
  final Future<void> Function(String segment) onOpen;

  String _titleFor(String segment) {
    return switch (segment) {
      'business' => l10n.surveyTemplateBusinessTitle,
      'employee' => l10n.surveyTemplateEmployeeTitle,
      _ => l10n.surveyTemplateConsumerTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.offlineSurveysTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.black),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.offlineSurveysDesc,
          style: const TextStyle(color: AppColors.grey600, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onOpen(item.segment),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: AppColors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_titleFor(item.segment), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            l10n.offlineSurveyPendingBadge,
                            style: const TextStyle(color: AppColors.orangeDark, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const BossChevronIcon(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SurveyTemplateTile extends StatelessWidget {
  const _SurveyTemplateTile({
    required this.survey,
    required this.segmentLabel,
    this.locked = false,
    this.pendingOffline = false,
    this.onOpen,
  });

  final DynamicSurvey survey;
  final String segmentLabel;
  final bool locked;
  final bool pendingOffline;
  final VoidCallback? onOpen;

  IconData _iconForSegment(String segment) {
    switch (segment) {
      case 'business':
        return Icons.business_center_rounded;
      case 'employee':
        return Icons.badge_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _localizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (survey.segment) {
      'consumer' => l10n.surveyTemplateConsumerTitle,
      'business' => l10n.surveyTemplateBusinessTitle,
      'employee' => l10n.surveyTemplateEmployeeTitle,
      _ => survey.title,
    };
  }

  String _localizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (survey.segment) {
      'consumer' => l10n.surveyTemplateConsumerDesc,
      'business' => l10n.surveyTemplateBusinessDesc,
      'employee' => l10n.surveyTemplateEmployeeDesc,
      _ => survey.description ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: locked ? null : (onOpen ?? () => context.push('/survey/${survey.segment}')),
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pendingOffline ? AppColors.orange : AppColors.grey200),
            boxShadow: const [BoxShadow(color: Color(0x0F1A1A1A), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  locked
                      ? Icons.lock_outline_rounded
                      : pendingOffline
                          ? Icons.cloud_off_rounded
                          : _iconForSegment(survey.segment),
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_localizedTitle(context), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(segmentLabel, style: const TextStyle(color: AppColors.orangeDark, fontSize: 12, fontWeight: FontWeight.w600)),
                    if (pendingOffline) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.offlineSurveyPendingBadge,
                        style: const TextStyle(color: AppColors.orangeDark, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ] else if (_localizedDescription(context).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _localizedDescription(context),
                        style: const TextStyle(color: AppColors.grey600, fontSize: 13, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!locked) const BossChevronIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.squadName,
    required this.badge,
    required this.progress,
    required this.progressLabel,
    required this.targetReachedHint,
  });

  final String squadName;
  final String badge;
  final dynamic progress;
  final String progressLabel;
  final String targetReachedHint;

  @override
  Widget build(BuildContext context) {
    final completed = (progress?.completed as num?)?.toInt() ?? 0;
    final target = (progress?.target as num?)?.toInt() ?? 50;
    final safeTarget = target <= 0 ? 50 : target;
    final percentage = completed / safeTarget;
    final reached = completed >= safeTarget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(badge, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(child: Text(squadName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(progressLabel, style: const TextStyle(color: AppColors.grey600, fontSize: 13)),
              Text('$completed / $safeTarget', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage.clamp(0, 1).toDouble(),
              minHeight: 10,
              backgroundColor: AppColors.white,
              color: AppColors.orange,
            ),
          ),
          if (reached) ...[
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).surveyTargetSmashed(completed, safeTarget),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.orangeDark),
            ),
            const SizedBox(height: 4),
            Text(
              targetReachedHint,
              style: const TextStyle(color: AppColors.grey600, fontSize: 12, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _RankingsCard extends StatelessWidget {
  const _RankingsCard({
    required this.report,
    required this.title,
    required this.responsesLabel,
    required this.satisfactionLabel,
    required this.perHourLabel,
  });

  final dynamic report;
  final String title;
  final String responsesLabel;
  final String satisfactionLabel;
  final String perHourLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(label: responsesLabel, value: '${report.totalResponses}'),
              _MiniStat(label: satisfactionLabel, value: (report.avgSatisfaction as num).toStringAsFixed(1)),
              _MiniStat(label: perHourLabel, value: '${report.surveysPerHour}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.orangeDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey600), textAlign: TextAlign.center),
      ],
    );
  }
}

class _LockedServicesSection extends StatelessWidget {
  const _LockedServicesSection({required this.surveys, required this.l10n});

  final List<DynamicSurvey> surveys;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: AppColors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.servicesLockedTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.servicesLockedDesc,
            style: const TextStyle(color: AppColors.grey600, height: 1.45, fontSize: 14),
          ),
          if (surveys.isNotEmpty) ...[
            const SizedBox(height: 20),
            _ServiceTemplatesSection(surveys: surveys, l10n: l10n, locked: true),
          ],
        ],
      ),
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.orange, Color(0xFFFF8A50)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                count == 1 ? l10n.homeNewNotifications(1) : l10n.homeNewNotifications(count),
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
