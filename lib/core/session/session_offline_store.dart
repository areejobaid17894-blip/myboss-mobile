import 'dart:convert';

import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Last-known profile + squad so Home and surveys can open after a cold start offline.
class SessionOfflineStore {
  static const _profileKey = 'offline_profile_v1';
  static const _squadKey = 'offline_squad_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _prefs;
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile({String? userId}) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final profile = UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      if (userId != null && userId.isNotEmpty && profile.id != userId) return null;
      return profile;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSquad(Squad squad) async {
    final prefs = await _prefs;
    await prefs.setString(_squadKey, jsonEncode(squad.toJson()));
  }

  Future<Squad?> loadSquad() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_squadKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Squad.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSquad() async {
    final prefs = await _prefs;
    await prefs.remove(_squadKey);
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_profileKey);
    await prefs.remove(_squadKey);
  }
}
