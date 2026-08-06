import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/notifications/notification_route.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationsCubit>()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  String _formatTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    try {
      return DateFormat.yMMMd(locale).add_jm().format(date.toLocal());
    } catch (_) {
      return DateFormat.yMMMd('en').add_jm().format(date.toLocal());
    }
  }

  Future<void> _openNotification(BuildContext context, AppNotification item) async {
    final cubit = context.read<NotificationsCubit>();
    if (!item.isRead) {
      await cubit.markRead(item.id);
    }
    final route = item.route;
    if (route != null && route.isNotEmpty && route != '/notifications') {
      if (context.mounted) context.go(resolveNotificationRoute(route));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navNotifications),
        actions: const [LanguageToggleButton()],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }

          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: state.error != null && state.items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: AppErrorView(
                          failure: state.error!,
                          onRetry: () => context.read<NotificationsCubit>().load(),
                        ),
                      ),
                    ],
                  )
                : state.items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(32),
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.grey400),
                          const SizedBox(height: 16),
                          Text(
                            l10n.notificationsEmptyTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.notificationsEmptyBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.grey600),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _NotificationCard(
                            item: item,
                            timeLabel: _formatTime(context, item.sentAt ?? item.createdAt),
                            onTap: () => _openNotification(context, item),
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  final AppNotification item;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BossCard(
      onTap: onTap,
      borderColor: item.isRead ? AppColors.grey200 : AppColors.orange.withValues(alpha: 0.35),
      borderWidth: item.isRead ? 1 : 1.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isRead ? AppColors.grey100 : AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.campaign_rounded,
              color: item.isRead ? AppColors.grey600 : AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: const TextStyle(color: AppColors.grey600, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(timeLabel, style: const TextStyle(fontSize: 12, color: AppColors.grey400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
