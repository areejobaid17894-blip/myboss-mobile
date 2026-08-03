import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';

/// Squad membership gates service templates, surveys, and gallery uploads.
/// Prefer live squad in session; fall back to profile squadId only before
/// membership is confirmed absent.
bool hasActiveSquad(SessionManager session) {
  if (session.currentSquad != null) return true;
  if (session.confirmedNoSquad) return false;
  final squadId = session.currentUser?.squadId;
  return squadId != null && squadId.isNotEmpty;
}

String? activeSquadId(SessionManager session) =>
    session.currentSquad?.id ?? session.currentUser?.squadId;

/// Main shell is reachable after sign-in. Squad-specific features stay locked
/// until [hasActiveSquad] is true.
bool canAccessMainApp(SessionManager session) => session.currentUser != null;

bool hasPendingJoinRequest(SquadJoinStatus? status) =>
    status?.hasPendingJoinRequest ?? false;
