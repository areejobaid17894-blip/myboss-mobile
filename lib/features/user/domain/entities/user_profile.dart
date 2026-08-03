import 'package:equatable/equatable.dart';

/// Full user profile as returned by the user-service, richer than the
/// lightweight [User] entity produced during authentication.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.onboardingCompleted,
    this.termsAcceptedAt,
    this.vestSize,
    this.buildingId,
    this.buildingName,
    this.governorate,
    this.openToTravel,
    this.squadId,
    this.profileEditCount = 0,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool onboardingCompleted;
  final String? termsAcceptedAt;
  final String? vestSize;
  final String? buildingId;
  final String? buildingName;
  final String? governorate;
  final bool? openToTravel;
  final String? squadId;
  final int profileEditCount;

  String get displayName => '$firstName $lastName'.trim();

  bool get hasAcceptedTerms => (termsAcceptedAt ?? '').trim().isNotEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'employee',
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      termsAcceptedAt: json['termsAcceptedAt'] as String?,
      vestSize: json['vestSize'] as String?,
      buildingId: json['buildingId'] as String?,
      buildingName: json['buildingName'] as String?,
      governorate: json['governorate'] as String?,
      openToTravel: json['openToTravel'] as bool?,
      squadId: json['squadId'] as String?,
      profileEditCount: json['profileEditCount'] as int? ?? 0,
    );
  }

  UserProfile copyWith({
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    bool? onboardingCompleted,
    String? termsAcceptedAt,
    String? squadId,
    bool clearSquadId = false,
    int? profileEditCount,
  }) {
    return UserProfile(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      vestSize: vestSize ?? this.vestSize,
      buildingId: buildingId ?? this.buildingId,
      buildingName: buildingName ?? this.buildingName,
      governorate: governorate ?? this.governorate,
      openToTravel: openToTravel ?? this.openToTravel,
      squadId: clearSquadId ? null : (squadId ?? this.squadId),
      profileEditCount: profileEditCount ?? this.profileEditCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        onboardingCompleted,
        termsAcceptedAt,
        vestSize,
        buildingId,
        buildingName,
        governorate,
        openToTravel,
        squadId,
        profileEditCount,
      ];
}

const vestSizes = ['S', 'M', 'L', 'XL', 'XXL', '3XL'];
