import 'package:flutter/foundation.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';

/// Holds the currently authenticated user's profile and squad in memory for
/// the lifetime of the app session. Registered as a lazy singleton in the DI
/// container so any feature can read/update the active session.
class SessionManager extends ChangeNotifier {
  UserProfile? _currentUser;
  Squad? _currentSquad;
  bool _confirmedNoSquad = false;

  UserProfile? get currentUser => _currentUser;
  Squad? get currentSquad => _currentSquad;
  bool get confirmedNoSquad => _confirmedNoSquad;

  bool get isAuthenticated => _currentUser != null;

  void setUser(UserProfile user) {
    _currentUser = user;
    notifyListeners();
  }

  void setSquad(Squad? squad) {
    _currentSquad = squad;
    if (squad != null) {
      _confirmedNoSquad = false;
    }
    notifyListeners();
  }

  void markConfirmedNoSquad() {
    _currentSquad = null;
    _confirmedNoSquad = true;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _currentSquad = null;
    _confirmedNoSquad = false;
    notifyListeners();
  }
}
