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
    this.route,
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
  final String? route;
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
      route: json['route'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, squadId, governorate, type, url, caption, source, title, notificationId, route, createdAt];
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


String _jsonString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

bool _jsonBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
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
    this.v,
    this.type,
    this.entityId,
    this.route,
    this.sentAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String body;
  final String audience;
  final String galleryItemId;
  final DateTime createdAt;
  final bool isRead;
  final String? v;
  final String? type;
  final String? entityId;
  final String? route;
  final DateTime? sentAt;
  final String? imageUrl;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  AppNotification copyWith({bool? isRead, String? imageUrl}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      audience: audience,
      galleryItemId: galleryItemId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      v: v,
      type: type,
      entityId: entityId,
      route: route,
      sentAt: sentAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _jsonString(json['id']),
      title: _jsonString(json['title']),
      body: _jsonString(json['body']),
      audience: _jsonString(json['audience']),
      galleryItemId: _jsonString(json['galleryItemId']),
      createdAt: DateTime.tryParse(_jsonString(json['createdAt'])) ?? DateTime.now(),
      isRead: _jsonBool(json['isRead']),
      v: _jsonString(json['v']).isEmpty ? null : _jsonString(json['v']),
      type: _jsonString(json['type']).isEmpty ? null : _jsonString(json['type']),
      entityId: _jsonString(json['entityId']).isEmpty ? null : _jsonString(json['entityId']),
      route: _jsonString(json['route']).isEmpty ? null : _jsonString(json['route']),
      sentAt: DateTime.tryParse(_jsonString(json['sentAt'])),
      imageUrl: _jsonString(json['imageUrl']).isEmpty ? null : _jsonString(json['imageUrl']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        audience,
        galleryItemId,
        createdAt,
        isRead,
        v,
        type,
        entityId,
        route,
        sentAt,
        imageUrl,
      ];
}
