import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  testWidgets('AppLocalizations loads English strings', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(l10n.sendMyCode);
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Send my code'), findsOneWidget);
  });

  test('configureDependencies registers AuthBloc', () async {
    await configureDependencies();
    expect(getIt.isRegistered<AuthBloc>(), isTrue);
  });
}
