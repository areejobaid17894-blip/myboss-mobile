import 'package:flutter/foundation.dart';

const _isDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

const demoAccountEmail = 'demo@orange.com';

class DemoTestAccount {
  const DemoTestAccount({
    required this.email,
    required this.label,
    required this.scenario,
  });

  final String email;
  final String label;
  final String scenario;
}

/// Seed employee accounts for demo QA (matches backend seed + admin docs).
const demoTestAccounts = [
  DemoTestAccount(
    email: 'demo@orange.com',
    label: 'Demo User',
    scenario: 'In squad — full happy path (surveys, chat, gallery)',
  ),
  DemoTestAccount(
    email: 'nisreen.a@orange.com',
    label: 'Nisreen A.',
    scenario: 'Squad leader — Orange Amman Squad',
  ),
  DemoTestAccount(
    email: 'omar.t@orange.com',
    label: 'Omar T.',
    scenario: 'Onboarded, no squad — chat & gallery upload locked',
  ),
  DemoTestAccount(
    email: 'laila.m@orange.com',
    label: 'Laila M.',
    scenario: 'Unregistered — onboarding flow only',
  ),
];

@Deprecated('Use demoTestAccounts')
const otherTestAccountEmails = [
  'nisreen.a@orange.com',
  'omar.t@orange.com',
  'laila.m@orange.com',
];

/// Pre-filled employee email in debug / demo builds.
String get demoEmployeeEmail => (kDebugMode || _isDemoMode) ? demoAccountEmail : '';

bool get isDemoBuild => kDebugMode || _isDemoMode;
