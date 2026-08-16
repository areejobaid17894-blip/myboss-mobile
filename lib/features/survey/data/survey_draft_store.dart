import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local survey progress + offline pending submissions.
class SurveyDraftStore {
  static const _draftPrefix = 'survey_draft_v1_';
  static const _pendingKey = 'survey_pending_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _draftKey({required String userId, required String segment}) =>
      '$_draftPrefix${userId}_$segment';

  Future<void> saveProgress(SurveyDraft draft) async {
    final prefs = await _prefs;
    await prefs.setString(
      _draftKey(userId: draft.userId, segment: draft.segment),
      jsonEncode(draft.toJson()),
    );
  }

  Future<SurveyDraft?> loadProgress({
    required String userId,
    required String segment,
    required String surveyId,
  }) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_draftKey(userId: userId, segment: segment));
    if (raw == null || raw.isEmpty) return null;
    try {
      final draft = SurveyDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (draft.surveyId != surveyId || draft.userId != userId) return null;
      return draft;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearProgress({required String userId, required String segment}) async {
    final prefs = await _prefs;
    await prefs.remove(_draftKey(userId: userId, segment: segment));
  }

  Future<void> enqueuePending(SurveyPendingSubmission pending) async {
    final prefs = await _prefs;
    final list = await listPending();
    final withoutDup = list
        .where(
          (item) =>
              !(item.userId == pending.userId &&
                  item.surveyId == pending.surveyId &&
                  item.segment == pending.segment),
        )
        .toList();
    withoutDup.add(pending);
    await prefs.setString(
      _pendingKey,
      jsonEncode(withoutDup.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<SurveyPendingSubmission>> listPending() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => SurveyPendingSubmission.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> savePendingList(List<SurveyPendingSubmission> items) async {
    final prefs = await _prefs;
    if (items.isEmpty) {
      await prefs.remove(_pendingKey);
      return;
    }
    await prefs.setString(
      _pendingKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removePending({
    required String userId,
    required String surveyId,
    required String segment,
  }) async {
    final remaining = (await listPending())
        .where(
          (item) =>
              !(item.userId == userId &&
                  item.surveyId == surveyId &&
                  item.segment == segment),
        )
        .toList();
    await savePendingList(remaining);
  }
}

class SurveyDraft {
  const SurveyDraft({
    required this.surveyId,
    required this.segment,
    required this.userId,
    required this.squadId,
    required this.governorate,
    required this.answers,
    required this.currentIndex,
    required this.updatedAt,
    this.pendingSubmit = false,
  });

  final String surveyId;
  final String segment;
  final String userId;
  final String squadId;
  final String governorate;
  final Map<String, dynamic> answers;
  final int currentIndex;
  final DateTime updatedAt;
  final bool pendingSubmit;

  Map<String, dynamic> toJson() => {
        'surveyId': surveyId,
        'segment': segment,
        'userId': userId,
        'squadId': squadId,
        'governorate': governorate,
        'answers': answers,
        'currentIndex': currentIndex,
        'updatedAt': updatedAt.toIso8601String(),
        'pendingSubmit': pendingSubmit,
      };

  factory SurveyDraft.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    return SurveyDraft(
      surveyId: json['surveyId']?.toString() ?? '',
      segment: json['segment']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      squadId: json['squadId']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
      answers: rawAnswers is Map
          ? Map<String, dynamic>.from(rawAnswers)
          : <String, dynamic>{},
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      pendingSubmit: json['pendingSubmit'] == true,
    );
  }
}

class SurveyPendingSubmission {
  const SurveyPendingSubmission({
    required this.surveyId,
    required this.segment,
    required this.userId,
    required this.squadId,
    required this.governorate,
    required this.answers,
    required this.savedAt,
    this.anonymous = false,
  });

  final String surveyId;
  final String segment;
  final String userId;
  final String squadId;
  final String governorate;
  final Map<String, dynamic> answers;
  final DateTime savedAt;
  final bool anonymous;

  List<Map<String, dynamic>> get answerPayload =>
      answers.entries.map((e) => {'questionId': e.key, 'value': e.value}).toList();

  Map<String, dynamic> toJson() => {
        'surveyId': surveyId,
        'segment': segment,
        'userId': userId,
        'squadId': squadId,
        'governorate': governorate,
        'answers': answers,
        'savedAt': savedAt.toIso8601String(),
        'anonymous': anonymous,
      };

  factory SurveyPendingSubmission.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    return SurveyPendingSubmission(
      surveyId: json['surveyId']?.toString() ?? '',
      segment: json['segment']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      squadId: json['squadId']?.toString() ?? '',
      governorate: json['governorate']?.toString() ?? '',
      answers: rawAnswers is Map
          ? Map<String, dynamic>.from(rawAnswers)
          : <String, dynamic>{},
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ?? DateTime.now(),
      anonymous: json['anonymous'] == true,
    );
  }
}
