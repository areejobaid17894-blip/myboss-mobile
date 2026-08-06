import 'package:flutter/foundation.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';

/// Shared unread badge count for bottom nav + home banner.
class NotificationUnreadTracker extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void update(int count) {
    if (_count == count) return;
    _count = count;
    notifyListeners();
  }

  void updateFromItems(List<AppNotification> items) {
    update(items.where((item) => !item.isRead).length);
  }
}
