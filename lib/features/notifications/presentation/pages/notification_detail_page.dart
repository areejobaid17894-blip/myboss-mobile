import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_design_widgets.dart';
import 'package:myboss_mobile/core/widgets/remote_image_url.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/core/notifications/notification_unread_tracker.dart';
import 'package:myboss_mobile/features/gallery/domain/usecases/gallery_usecases.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage({super.key, required this.notificationId, this.initial});

  final String notificationId;
  final AppNotification? initial;

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  AppNotification? _item;
  bool _loading = true;
  bool _markingRead = false;

  @override
  void initState() {
    super.initState();
    _item = widget.initial;
    _load();
  }

  Future<void> _load() async {
    if (_item != null) {
      setState(() => _loading = false);
      await _ensureRead(_item!);
      return;
    }

    final userId = getIt<SessionManager>().currentUser?.id ?? '';
    if (userId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final response = await getIt<GetNotificationByIdUseCase>()(id: widget.notificationId, userId: userId);
    if (!mounted) return;

    if (response.item != null) {
      setState(() {
        _item = response.item;
        _loading = false;
      });
      await _ensureRead(response.item!);
      return;
    }

    setState(() => _loading = false);
  }

  Future<void> _ensureRead(AppNotification item) async {
    if (item.isRead || _markingRead) return;
    _markingRead = true;
    try {
      final session = getIt<SessionManager>();
      final user = session.currentUser;
      final userId = user?.id ?? '';
      if (userId.isEmpty) return;

      await getIt<MarkNotificationReadUseCase>()(notificationId: item.id, userId: userId);

      final squad = session.currentSquad;
      final listResponse = await getIt<GetNotificationsForUserUseCase>()(
        userId: userId,
        onboardingCompleted: user?.onboardingCompleted,
        openToTravel: user?.openToTravel,
        isLeader: squad?.isLeader(userId) ?? false,
      );
      if (listResponse.failure == null) {
        getIt<NotificationUnreadTracker>().updateFromItems(listResponse.items);
      } else {
        final tracker = getIt<NotificationUnreadTracker>();
        tracker.update(tracker.count > 0 ? tracker.count - 1 : 0);
      }

      if (mounted) {
        setState(() => _item = item.copyWith(isRead: true));
      }
    } finally {
      _markingRead = false;
    }
  }

  String _formatTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    try {
      return DateFormat.yMMMd(locale).add_jm().format(date.toLocal());
    } catch (_) {
      return DateFormat.yMMMd('en').add_jm().format(date.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.notificationDetailTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _item == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.notificationNotFound, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    if (_item!.hasImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: RemoteImageUrl(url: _item!.imageUrl!),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _item!.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.black),
                          ),
                        ),
                        if (!_item!.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.notificationUnreadBadge,
                              style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(context, _item!.sentAt ?? _item!.createdAt),
                      style: TextStyle(color: AppColors.grey600, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    BossCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        _item!.body,
                        style: const TextStyle(fontSize: 16, height: 1.55, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
    );
  }
}
