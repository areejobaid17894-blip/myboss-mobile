import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/auth/otp_session_store.dart';
import 'package:myboss_mobile/core/router/otp_route_args.dart';

OtpRouteArgs resolveOtpRouteArgs(GoRouterState state) {
  final args = state.extra as OtpRouteArgs?;
  final stored = OtpSessionStore.read();

  final sessionId = _firstNonEmpty([
    args?.sessionId,
    state.uri.queryParameters['sessionId'],
    stored?.sessionId,
  ]);

  final email = _firstNonEmpty([
    args?.email,
    state.uri.queryParameters['email'],
    stored?.email,
  ]);

  final demoOtpCode = _firstNonEmpty([
    args?.demoOtpCode,
    state.uri.queryParameters['demoOtp'],
    stored?.demoOtpCode,
  ]);

  return OtpRouteArgs(
    sessionId: sessionId,
    email: email,
    demoOtpCode: demoOtpCode.isEmpty ? null : demoOtpCode,
  );
}

void syncOtpSessionStore(OtpRouteArgs args) {
  if (args.sessionId.isEmpty || args.email.isEmpty) return;
  OtpSessionStore.save(
    sessionId: args.sessionId,
    email: args.email,
    demoOtpCode: args.demoOtpCode,
  );
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}
