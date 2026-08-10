import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/core/widgets/remote_image_url.dart';
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

  void _openNotification(BuildContext context, AppNotification item) {
    context.push('/notifications/${item.id}', extra: item).then((_) {
      if (context.mounted) {
        context.read<NotificationsCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.unreadCount > 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.navNotifications),
                  Text(
                    l10n.notificationsUnreadSummary(state.unreadCount),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.grey600),
                  ),
                ],
              );
            }
            return Text(l10n.navNotifications);
          },
        ),
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
          if (item.hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: RemoteImageUrl(url: item.imageUrl!),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.isRead ? AppColors.grey100 : AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.campaign_rounded,
                color: item.isRead ? AppColors.grey600 : AppColors.orange,
                size: 24,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.grey600, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(timeLabel, style: const TextStyle(fontSize: 12, color: AppColors.grey400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        ],
      ),
    );
  }
}
