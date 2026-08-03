import 'package:equatable/equatable.dart';

class GalleryItem extends Equatable {
  const GalleryItem({
    required this.id,
    required this.userId,
    required this.squadId,
    required this.governorate,
    required this.type,
    required this.url,
    required this.createdAt,
    this.caption,
    this.source = 'employee',
    this.title,
    this.notificationId,
  });

  final String id;
  final String userId;
  final String squadId;
  final String governorate;
  final String type; // image | video | announcement
  final String url;
  final String? caption;
  final String source; // employee | admin
  final String? title;
  final String? notificationId;
  final DateTime createdAt;

  bool get isAnnouncement => type == 'announcement' || source == 'admin';

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      squadId: json['squadId'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      url: json['url'] as String? ?? '',
      caption: json['caption'] as String?,
      source: json['source'] as String? ?? 'employee',
      title: json['title'] as String?,
      notificationId: json['notificationId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, squadId, governorate, type, url, caption, source, title, notificationId, createdAt];
}

class GalleryFeed extends Equatable {
  const GalleryFeed({required this.items, required this.grouped});

  final List<GalleryItem> items;
  final Map<String, List<GalleryItem>> grouped;

  factory GalleryFeed.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final groupedJson = json['grouped'] as Map<String, dynamic>? ?? {};
    final grouped = groupedJson.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => GalleryItem.fromJson(e as Map<String, dynamic>)).toList(),
      ),
    );
    return GalleryFeed(items: items, grouped: grouped);
  }

  @override
  List<Object?> get props => [items, grouped];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.galleryItemId,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String audience;
  final String galleryItemId;
  final DateTime createdAt;
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      audience: json['audience'] as String? ?? '',
      galleryItemId: json['galleryItemId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, body, audience, galleryItemId, createdAt, isRead];
}
