class EmployeeSettings {
  const EmployeeSettings({
    required this.profileEditLimit,
    required this.vestSizeEditWindowStart,
    required this.vestSizeEditWindowEnd,
    this.squadJoinDeadline = '',
    this.adminContactEmail = defaultAdminContactEmail,
  });

  static const defaultAdminContactEmail = 'areej.obaid@orange.com';

  final int profileEditLimit;
  final String vestSizeEditWindowStart;
  final String vestSizeEditWindowEnd;
  final String squadJoinDeadline;
  final String adminContactEmail;

  factory EmployeeSettings.fromJson(Map<String, dynamic> json) {
    final email = (json['adminContactEmail'] as String? ?? '').trim();
    return EmployeeSettings(
      profileEditLimit: (json['profileEditLimit'] as num?)?.toInt() ?? 2,
      vestSizeEditWindowStart: json['vestSizeEditWindowStart'] as String? ?? '',
      vestSizeEditWindowEnd: json['vestSizeEditWindowEnd'] as String? ?? '',
      squadJoinDeadline: json['squadJoinDeadline'] as String? ?? '',
      adminContactEmail: email.isEmpty ? defaultAdminContactEmail : email,
    );
  }

  bool get hasVestSizeEditWindow =>
      vestSizeEditWindowStart.trim().isNotEmpty && vestSizeEditWindowEnd.trim().isNotEmpty;

  bool get hasSquadJoinDeadline => squadJoinDeadline.trim().isNotEmpty;

  bool isEmployeeJoinClosed([DateTime? now]) {
    if (!hasSquadJoinDeadline) return false;
    final end = DateTime.tryParse('${squadJoinDeadline.trim()}T23:59:59');
    if (end == null) return false;
    return (now ?? DateTime.now()).isAfter(end);
  }

  bool isWithinVestSizeEditWindow([DateTime? now]) {
    final current = now ?? DateTime.now();
    if (vestSizeEditWindowStart.trim().isEmpty || vestSizeEditWindowEnd.trim().isEmpty) {
      return false;
    }
    final from = DateTime.tryParse('${vestSizeEditWindowStart.trim()}T00:00:00');
    final to = DateTime.tryParse('${vestSizeEditWindowEnd.trim()}T23:59:59');
    if (from == null || to == null) return false;
    return !current.isBefore(from) && !current.isAfter(to);
  }

  bool canEditProfile(int profileEditCount) {
    if (profileEditCount >= profileEditLimit) return false;
    if (profileEditCount == 0) return true;
    return isWithinVestSizeEditWindow();
  }
}
