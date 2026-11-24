import 'package:flutter_test/flutter_test.dart';
import 'package:qlcskb/models/team_model.dart';

void main() {
  group('Team & Member Models Tests', () {
    test('Team model serialization & parsing', () {
      final now = DateTime.now();
      final team = Team(
        id: 'team-1',
        code: 'CSKB-7890',
        name: 'Team Up CSKB Vũ Trụ 1',
        ownerName: 'Goku',
        createdAt: now,
      );

      final map = team.toMap();
      expect(map['code'], 'CSKB-7890');
      expect(map['name'], 'Team Up CSKB Vũ Trụ 1');
      expect(map['owner_name'], 'Goku');

      final fromMap = Team.fromMap(map);
      expect(fromMap.code, team.code);
      expect(fromMap.name, team.name);
      expect(fromMap.ownerName, team.ownerName);
    });

    test('TeamMember model serialization & roles', () {
      final now = DateTime.now();
      final member = TeamMember(
        id: 'member-1',
        teamCode: 'CSKB-7890',
        memberName: 'Vegeta',
        role: 'FARMER',
        lastActive: now,
      );

      final map = member.toMap();
      expect(map['team_code'], 'CSKB-7890');
      expect(map['member_name'], 'Vegeta');
      expect(map['role'], 'FARMER');

      final fromMap = TeamMember.fromMap(map);
      expect(fromMap.teamCode, member.teamCode);
      expect(fromMap.memberName, member.memberName);
      expect(fromMap.role, 'FARMER');
    });
  });
}
