import 'package:equatable/equatable.dart';

class SquadMember extends Equatable {
  const SquadMember({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.building,
    this.openToTravel,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String role; // leader | member
  final String? building;
  final bool? openToTravel;

  String get displayName => '$firstName $lastName'.trim();
  bool get isLeader => role == 'leader';

  factory SquadMember.fromJson(Map<String, dynamic> json) {
    return SquadMember(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      building: json['building'] as String?,
      openToTravel: json['openToTravel'] as bool?,
    );
  }

  @override
  List<Object?> get props => [userId, firstName, lastName, role, building, openToTravel];
}

class SquadJoinRequest extends Equatable {
  const SquadJoinRequest({
    required this.id,
    required this.squadId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.createdAt,
    this.building,
  });

  final String id;
  final String squadId;
  final String userId;
  final String firstName;
  final String lastName;
  final String? building;
  final String status; // pending | accepted | rejected | cancelled
  final DateTime createdAt;

  String get displayName => '$firstName $lastName'.trim();
  bool get isPending => status == 'pending';

  factory SquadJoinRequest.fromJson(Map<String, dynamic> json) {
    return SquadJoinRequest(
      id: json['id'] as String,
      squadId: json['squadId'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      building: json['building'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, squadId, userId, firstName, lastName, building, status, createdAt];
}

/// Full squad detail (leader/member view) as returned by create/getById/mySquad.
class Squad extends Equatable {
  const Squad({
    required this.id,
    required this.squadCode,
    required this.name,
    required this.badge,
    required this.governorate,
    required this.leaderId,
    required this.members,
    required this.joinRequests,
    required this.surveyTarget,
    required this.createdAt,
    this.destination,
    this.destinationValidated = false,
    this.lockedAt,
  });

  final String id;
  final String squadCode;
  final String name;
  final String badge;
  final String governorate;
  final String leaderId;
  final List<SquadMember> members;
  final List<SquadJoinRequest> joinRequests;
  final String? destination;
  final bool destinationValidated;
  final int surveyTarget;
  final DateTime createdAt;
  final String? lockedAt;

  bool isLeader(String userId) => leaderId == userId;

  List<SquadJoinRequest> get pendingRequests =>
      joinRequests.where((r) => r.isPending).toList();

  factory Squad.fromJson(Map<String, dynamic> json) {
    return Squad(
      id: json['id'] as String,
      squadCode: json['squadCode'] as String? ?? '',
      name: json['name'] as String,
      badge: json['badge'] as String? ?? '🦅',
      governorate: json['governorate'] as String? ?? '',
      leaderId: json['leaderId'] as String,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => SquadMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      joinRequests: (json['joinRequests'] as List<dynamic>? ?? [])
          .map((e) => SquadJoinRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      destination: json['destination'] as String?,
      destinationValidated: json['destinationValidated'] as bool? ?? false,
      surveyTarget: json['surveyTarget'] as int? ?? 50,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      lockedAt: json['lockedAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        squadCode,
        name,
        badge,
        governorate,
        leaderId,
        members,
        joinRequests,
        destination,
        destinationValidated,
        surveyTarget,
        createdAt,
        lockedAt,
      ];
}

/// Lightweight squad used for browse/search-to-join lists.
class PublicSquad extends Equatable {
  const PublicSquad({
    required this.id,
    required this.squadCode,
    required this.name,
    required this.badge,
    required this.governorate,
    required this.memberCount,
    required this.maxMembers,
    required this.isFull,
  });

  final String id;
  final String squadCode;
  final String name;
  final String badge;
  final String governorate;
  final int memberCount;
  final int maxMembers;
  final bool isFull;

  factory PublicSquad.fromJson(Map<String, dynamic> json) {
    return PublicSquad(
      id: json['id']?.toString() ?? '',
      squadCode: json['squadCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      badge: json['badge'] as String? ?? '🦅',
      governorate: json['governorate'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 5,
      isFull: json['isFull'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, squadCode, name, badge, governorate, memberCount, maxMembers, isFull];
}

class SquadStats extends Equatable {
  const SquadStats({required this.totalSquads, required this.maxSquads, required this.remaining});

  final int totalSquads;
  final int maxSquads;
  final int remaining;

  factory SquadStats.fromJson(Map<String, dynamic> json) {
    return SquadStats(
      totalSquads: json['totalSquads'] as int? ?? 0,
      maxSquads: json['maxSquads'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalSquads, maxSquads, remaining];
}

class SquadJoinStatus extends Equatable {
  const SquadJoinStatus({
    required this.inSquad,
    required this.hasPendingJoinRequest,
    this.squadId,
    this.squadName,
    this.requestId,
  });

  final bool inSquad;
  final bool hasPendingJoinRequest;
  final String? squadId;
  final String? squadName;
  final String? requestId;

  bool get canCreateOrJoin => !inSquad && !hasPendingJoinRequest;

  factory SquadJoinStatus.fromJson(Map<String, dynamic> json) {
    return SquadJoinStatus(
      inSquad: json['inSquad'] as bool? ?? false,
      hasPendingJoinRequest: json['hasPendingJoinRequest'] as bool? ?? false,
      squadId: json['squadId'] as String?,
      squadName: json['squadName'] as String?,
      requestId: json['requestId'] as String?,
    );
  }

  @override
  List<Object?> get props => [inSquad, hasPendingJoinRequest, squadId, squadName, requestId];
}

/// Badges available in the create-squad picker (client-side only — backend
/// accepts any free-form string).
const squadBadges = ['🦅', '🐺', '🦁', '🐯', '🐻', '🦊', '🐉', '🦂', '🦈', '🚀', '⚡', '🔥'];
