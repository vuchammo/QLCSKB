class Team {
  final String id;
  final String code; // Mã chia sẻ (ví dụ: CSKB-8392)
  final String name; // Tên đội nhóm
  final String ownerName; // Tên trưởng nhóm
  final DateTime createdAt;

  Team({
    required this.id,
    required this.code,
    required this.name,
    required this.ownerName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'owner_name': ownerName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id']?.toString() ?? '',
      code: map['code'] as String,
      name: map['name'] as String,
      ownerName: map['owner_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class TeamMember {
  final String id;
  final String teamCode;
  final String memberName;
  final String role; // OWNER, FARMER, TRADER, MEMBER
  final DateTime lastActive;

  TeamMember({
    required this.id,
    required this.teamCode,
    required this.memberName,
    this.role = 'MEMBER',
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'team_code': teamCode,
      'member_name': memberName,
      'role': role,
      'last_active': lastActive.toIso8601String(),
    };
  }

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id']?.toString() ?? '',
      teamCode: map['team_code'] as String,
      memberName: map['member_name'] as String,
      role: (map['role'] as String?) ?? 'MEMBER',
      lastActive: DateTime.parse(map['last_active'] as String),
    );
  }
}
