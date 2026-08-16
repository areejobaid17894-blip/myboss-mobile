import 'package:flutter/foundation.dart';

const _isDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

const demoAccountEmail = 'areej.obaid@orange.com';

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
    email: 'areej.obaid@orange.com',
    label: 'Areej O.',
    scenario: 'Employee happy path — in Amman squad (surveys, chat, gallery)',
  ),
  DemoTestAccount(
    email: 'demo@orange.com',
    label: 'Demo User',
    scenario: 'In squad — full happy path (surveys, chat, gallery)',
  ),
  DemoTestAccount(
    email: 'nisreen.a@orange.com',
    label: 'Nisreen A.',
    scenario: 'Squad leader — Orange Amman Squad (join requests)',
  ),
  DemoTestAccount(
    email: 'omar.t@orange.com',
    label: 'Omar T.',
    scenario: 'Onboarded, no squad — chat & gallery upload locked',
  ),
  DemoTestAccount(
    email: 'laila.m@orange.com',
    label: 'Laila M.',
    scenario: 'Needs onboarding — profile + destinations flow',
  ),
  DemoTestAccount(
    email: 'demo.terms@orange.com',
    label: 'Rana K.',
    scenario: 'Onboarded, terms not accepted — terms popup first',
  ),
  DemoTestAccount(
    email: 'demo.join@orange.com',
    label: 'Huda S.',
    scenario: 'Pending join request — waiting on Amman squad leader',
  ),
  DemoTestAccount(
    email: 'demo.travel@orange.com',
    label: 'Sami A.',
    scenario: 'No squad, open to travel — allocation candidate (Irbid/Zarqa)',
  ),
  DemoTestAccount(
    email: 'sara.h@orange.com',
    label: 'Sara H.',
    scenario: 'Squad leader — Orange Irbid Squad',
  ),
  DemoTestAccount(
    email: 'khaled.r@orange.com',
    label: 'Khaled R.',
    scenario: 'Squad leader — Orange Zarqa Squad',
  ),
  DemoTestAccount(
    email: 'demo.unknown@orange.com',
    label: 'Not eligible',
    scenario: 'Not in participant list — sign-in returns 403',
  ),
];

/// Pre-filled employee email in debug / demo builds.
String get demoEmployeeEmail => (kDebugMode || _isDemoMode) ? demoAccountEmail : '';

bool get isDemoBuild => kDebugMode || _isDemoMode;
