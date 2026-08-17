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
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      building: json['building'] as String?,
      openToTravel: json['openToTravel'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'building': building,
        'openToTravel': openToTravel,
      };

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
    this.kind = 'join',
  });

  final String id;
  final String squadId;
  final String userId;
  final String firstName;
  final String lastName;
  final String? building;
  final String status; // pending | accepted | rejected | cancelled
  final String kind; // join | invite
  final DateTime createdAt;

  String get displayName => '$firstName $lastName'.trim();
  bool get isPending => status == 'pending';
  bool get isInvite => kind == 'invite';
  bool get isJoinRequest => kind != 'invite';

  factory SquadJoinRequest.fromJson(Map<String, dynamic> json) {
    return SquadJoinRequest(
      id: json['id']?.toString() ?? '',
      squadId: json['squadId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      building: json['building'] as String?,
      status: json['status'] as String? ?? 'pending',
      kind: json['kind'] as String? ?? 'join',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'squadId': squadId,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'building': building,
        'status': status,
        'kind': kind,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, squadId, userId, firstName, lastName, building, status, kind, createdAt];
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
    this.maxMembers = defaultMaxMembers,
    this.remainingSeats,
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
  final int maxMembers;
  final int? remainingSeats;

  bool isLeader(String userId) => leaderId == userId;

  /// Matches config default / HTML prototype (5/5).
  static const int defaultMaxMembers = 5;

  int get seatsLeft {
    if (remainingSeats != null) return remainingSeats!.clamp(0, maxMembers);
    final reserved = members.length + pendingRequests.length;
    return (maxMembers - reserved).clamp(0, maxMembers);
  }

  bool get isFull => seatsLeft <= 0;

  List<SquadJoinRequest> get pendingRequests =>
      joinRequests.where((r) => r.isPending).toList();

  List<SquadJoinRequest> get pendingJoinRequests =>
      pendingRequests.where((r) => r.isJoinRequest).toList();

  List<SquadJoinRequest> get pendingInvites =>
      pendingRequests.where((r) => r.isInvite).toList();

  factory Squad.fromJson(Map<String, dynamic> json) {
    final members = (json['members'] as List<dynamic>? ?? [])
        .map((e) => SquadMember.fromJson(e as Map<String, dynamic>))
        .toList();
    final joinRequests = (json['joinRequests'] as List<dynamic>? ?? [])
        .map((e) => SquadJoinRequest.fromJson(e as Map<String, dynamic>))
        .toList();
    final maxMembers = (json['maxMembers'] as num?)?.toInt() ?? defaultMaxMembers;
    final pendingCount = joinRequests.where((r) => r.isPending).length;
    return Squad(
      id: json['id']?.toString() ?? '',
      squadCode: json['squadCode']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      badge: json['badge'] as String? ?? '🦅',
      governorate: json['governorate'] as String? ?? '',
      leaderId: json['leaderId']?.toString() ?? '',
      members: members,
      joinRequests: joinRequests,
      destination: json['destination'] as String?,
      destinationValidated: json['destinationValidated'] as bool? ?? false,
      surveyTarget: (json['surveyTarget'] as num?)?.toInt() ?? 50,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      lockedAt: json['lockedAt'] as String?,
      maxMembers: maxMembers,
      remainingSeats: (json['remainingSeats'] as num?)?.toInt() ??
          (maxMembers - members.length - pendingCount).clamp(0, maxMembers),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'squadCode': squadCode,
        'name': name,
        'badge': badge,
        'governorate': governorate,
        'leaderId': leaderId,
        'members': members.map((e) => e.toJson()).toList(),
        'joinRequests': joinRequests.map((e) => e.toJson()).toList(),
        'destination': destination,
        'destinationValidated': destinationValidated,
        'surveyTarget': surveyTarget,
        'createdAt': createdAt.toIso8601String(),
        'lockedAt': lockedAt,
        'maxMembers': maxMembers,
        'remainingSeats': remainingSeats,
      };

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
        maxMembers,
        remainingSeats,
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
    this.kind,
    this.squadId,
    this.squadName,
    this.requestId,
  });

  final bool inSquad;
  final bool hasPendingJoinRequest;
  final String? kind; // join | invite
  final String? squadId;
  final String? squadName;
  final String? requestId;

  bool get isPendingInvite => hasPendingJoinRequest && kind == 'invite';
  bool get canCreateOrJoin => !inSquad && !hasPendingJoinRequest;

  factory SquadJoinStatus.fromJson(Map<String, dynamic> json) {
    return SquadJoinStatus(
      inSquad: json['inSquad'] as bool? ?? false,
      hasPendingJoinRequest: json['hasPendingJoinRequest'] as bool? ?? false,
      kind: json['kind'] as String?,
      squadId: json['squadId'] as String?,
      squadName: json['squadName'] as String?,
      requestId: json['requestId'] as String?,
    );
  }

  @override
  List<Object?> get props => [inSquad, hasPendingJoinRequest, kind, squadId, squadName, requestId];
}

class SuggestedSquadUser extends Equatable {
  const SuggestedSquadUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.governorate,
    this.buildingName,
    this.sameGovernorate = false,
    this.inSquadName,
    this.invited = false,
    this.unregistered = false,
    this.canInvite = true,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? governorate;
  final String? buildingName;
  final bool sameGovernorate;
  final String? inSquadName;
  final bool invited;
  final bool unregistered;
  final bool canInvite;

  String get displayName => '$firstName $lastName'.trim();

  factory SuggestedSquadUser.fromJson(Map<String, dynamic> json) {
    return SuggestedSquadUser(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String?,
      governorate: json['governorate'] as String?,
      buildingName: json['buildingName'] as String?,
      sameGovernorate: json['sameGovernorate'] as bool? ?? false,
      inSquadName: json['inSquadName'] as String?,
      invited: json['invited'] as bool? ?? false,
      unregistered: json['unregistered'] as bool? ?? false,
      canInvite: json['canInvite'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        governorate,
        buildingName,
        sameGovernorate,
        inSquadName,
        invited,
        unregistered,
        canInvite,
      ];
}

class SuggestedSquadMembers extends Equatable {
  const SuggestedSquadMembers({
    required this.remainingSeats,
    required this.maxMembers,
    required this.memberCount,
    required this.items,
  });

  final int remainingSeats;
  final int maxMembers;
  final int memberCount;
  final List<SuggestedSquadUser> items;

  factory SuggestedSquadMembers.fromJson(Map<String, dynamic> json) {
    return SuggestedSquadMembers(
      remainingSeats: (json['remainingSeats'] as num?)?.toInt() ?? 0,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? Squad.defaultMaxMembers,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => SuggestedSquadUser.fromJson(Map<String, dynamic>.from(e)))
          .where((u) => u.id.isNotEmpty)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [remainingSeats, maxMembers, memberCount, items];
}

/// Badges available in the create-squad picker (client-side only — backend
/// accepts any free-form string).
const squadBadges = ['🦅', '🐺', '🦁', '🐯', '🐻', '🦊', '🐉', '🦂', '🦈', '🚀', '⚡', '🔥'];
