import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/app/main_shell.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/app_redirect.dart';
import 'package:myboss_mobile/core/router/otp_route_resolver.dart';
import 'package:myboss_mobile/core/router/session_resolver_page.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:myboss_mobile/features/auth/presentation/pages/sign_in_page.dart';
import 'package:myboss_mobile/features/gallery/presentation/pages/gallery_page.dart';
import 'package:myboss_mobile/features/home/presentation/pages/home_page.dart';
import 'package:myboss_mobile/features/onboarding/presentation/pages/terms_acceptance_page.dart';
import 'package:myboss_mobile/features/onboarding/presentation/pages/building_mobility_page.dart';
import 'package:myboss_mobile/features/onboarding/presentation/pages/vest_size_page.dart';
import 'package:myboss_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/presentation/pages/create_squad_page.dart';
import 'package:myboss_mobile/features/squad/presentation/pages/join_squad_page.dart';
import 'package:myboss_mobile/features/squad/presentation/pages/my_squad_page.dart';
import 'package:myboss_mobile/features/squad/presentation/pages/squad_hub_page.dart';
import 'package:myboss_mobile/features/squad/presentation/pages/squad_success_page.dart';
import 'package:myboss_mobile/features/survey/presentation/pages/dynamic_survey_page.dart';
import 'package:myboss_mobile/features/chat/presentation/pages/live_chat_page.dart';
import 'package:myboss_mobile/features/survey/presentation/pages/reports_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

late final GoRouter appRouter;

void configureAppRouter() {
  final session = getIt<SessionManager>();
  appRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/sign-in',
    refreshListenable: session,
    redirect: (_, state) => resolveAppRedirect(state.uri.path),
    routes: _appRoutes,
  );
}

final _appRoutes = <RouteBase>[
    GoRoute(
      path: '/login',
      redirect: (_, __) => '/sign-in',
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final args = resolveOtpRouteArgs(state);
        syncOtpSessionStore(args);
        return OtpVerificationPage(
          sessionId: args.sessionId,
          email: args.email,
          demoOtpCode: args.demoOtpCode,
        );
      },
    ),
    GoRoute(
      path: '/resolve',
      builder: (context, state) {
        final userId = state.extra as String? ?? '';
        return SessionResolverPage(userId: userId);
      },
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding/terms',
      builder: (context, state) => const TermsAcceptancePage(),
    ),
    GoRoute(
      path: '/onboarding/vest-size',
      builder: (context, state) => const VestSizePage(),
    ),
    GoRoute(
      path: '/onboarding/building',
      builder: (context, state) {
        final session = getIt<SessionManager>();
        final vestSize = state.extra as String? ?? session.currentUser?.vestSize ?? 'M';
        return BuildingMobilityPage(vestSize: vestSize);
      },
    ),

    // Squad formation
    GoRoute(
      path: '/squad/hub',
      builder: (context, state) => const SquadHubPage(),
    ),
    GoRoute(
      path: '/squad/create',
      builder: (context, state) => const CreateSquadPage(),
    ),
    GoRoute(
      path: '/squad/join',
      builder: (context, state) => const JoinSquadPage(),
    ),
    GoRoute(
      path: '/squad/success',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return SquadSuccessPage(
          mode: extra['mode'] as String? ?? 'join',
          squad: extra['squad'] as Squad?,
        );
      },
    ),

    // Survey & chat (pushed on top of the shell)
    GoRoute(
      path: '/survey/:segment',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final segment = state.pathParameters['segment'] ?? 'consumer';
        return DynamicSurveyPage(segment: segment);
      },
    ),
    GoRoute(
      path: '/chat',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LiveChatPage(),
    ),

    // Authenticated shell with bottom navigation (Home, Reports, Gallery, My Squad, Profile)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/reports', builder: (context, state) => const ReportsPage(embedded: true)),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/gallery', builder: (context, state) => const GalleryPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/my-squad', builder: (context, state) => const MySquadPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
          ],
        ),
      ],
    ),
];
