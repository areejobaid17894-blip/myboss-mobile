import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/notifications/notification_unread_tracker.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/features/gallery/domain/usecases/gallery_usecases.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.isLoading = false,
    this.items = const [],
    this.unreadCount = 0,
    this.error,
  });

  final bool isLoading;
  final List<AppNotification> items;
  final int unreadCount;
  final Failure? error;

  NotificationsState copyWith({
    bool? isLoading,
    List<AppNotification>? items,
    int? unreadCount,
    Failure? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, items, unreadCount, error];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._listUseCase,
    this._markReadUseCase,
    this._unreadTracker,
  ) : super(const NotificationsState());

  final GetNotificationsForUserUseCase _listUseCase;
  final MarkNotificationReadUseCase _markReadUseCase;
  final NotificationUnreadTracker _unreadTracker;

  Future<void> load({Squad? squad}) async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, clearError: true));

    final session = getIt<SessionManager>();
    final user = session.currentUser;
    final userId = user?.id ?? '';
    if (userId.isEmpty) {
      if (!isClosed) emit(state.copyWith(isLoading: false, items: const [], unreadCount: 0));
      return;
    }

    final activeSquad = squad ?? session.currentSquad;
    final listResponse = await _listUseCase(
      userId: userId,
      onboardingCompleted: user?.onboardingCompleted,
      openToTravel: user?.openToTravel,
      isLeader: activeSquad?.isLeader(userId) ?? false,
    );

    if (listResponse.failure != null) {
      if (!isClosed) emit(state.copyWith(isLoading: false, error: listResponse.failure));
      return;
    }

    final unreadCount = listResponse.items.where((n) => !n.isRead).length;
    _unreadTracker.update(unreadCount);

    if (!isClosed) {
      emit(state.copyWith(
        isLoading: false,
        items: listResponse.items,
        unreadCount: unreadCount,
      ));
    }
  }

  Future<void> markRead(String notificationId) async {
    final userId = getIt<SessionManager>().currentUser?.id ?? '';
    if (userId.isEmpty || notificationId.isEmpty) return;

    await _markReadUseCase(notificationId: notificationId, userId: userId);
    final updated = state.items.map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n).toList();
    final unread = updated.where((n) => !n.isRead).length;
    _unreadTracker.update(unread);
    if (!isClosed) emit(state.copyWith(items: updated, unreadCount: unread));
  }
}
