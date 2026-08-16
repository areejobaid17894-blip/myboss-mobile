import 'dart:convert';

import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists survey catalog + full question schemas for offline opening.
class SurveySchemaCache {
  static const _catalogKey = 'survey_catalog_v1';
  static const _schemaPrefix = 'survey_schema_v1_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _schemaKey(String segment) => '$_schemaPrefix$segment';

  Future<void> saveSchema(DynamicSurvey survey) async {
    if (survey.segment.isEmpty || survey.questions.isEmpty) return;
    final prefs = await _prefs;
    await prefs.setString(_schemaKey(survey.segment), jsonEncode(survey.toJson()));
  }

  Future<void> saveCatalog(List<DynamicSurvey> surveys) async {
    final existing = {for (final survey in await listAll()) survey.segment: survey};
    final merged = surveys.map((survey) {
      final previous = existing[survey.segment];
      if (survey.questions.isEmpty && previous != null && previous.questions.isNotEmpty) {
        return previous;
      }
      return survey;
    }).toList();

    final prefs = await _prefs;
    await prefs.setString(
      _catalogKey,
      jsonEncode(merged.map((survey) => survey.toJson()).toList()),
    );
    for (final survey in merged) {
      await saveSchema(survey);
    }
  }

  Future<DynamicSurvey?> getBySegment(String segment) async {
    if (segment.isEmpty) return null;
    final prefs = await _prefs;
    final raw = prefs.getString(_schemaKey(segment));
    final fromSchema = _decodeSurvey(raw);
    if (fromSchema != null && fromSchema.questions.isNotEmpty) return fromSchema;

    for (final survey in await listAll()) {
      if (survey.segment == segment && survey.questions.isNotEmpty) return survey;
    }
    return fromSchema;
  }

  Future<List<DynamicSurvey>> listAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_catalogKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => DynamicSurvey.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  DynamicSurvey? _decodeSurvey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return DynamicSurvey.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}
