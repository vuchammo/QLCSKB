import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_model.dart';
import '../models/detector_purchase.dart';
import '../models/farming_session.dart';
import '../models/cskb_sale.dart';
import '../models/cskb_usage.dart';
import '../models/other_expense.dart';

class CloudResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  CloudResponse.success(this.data) : success = true, errorMessage = null;
  CloudResponse.failure(this.errorMessage) : success = false, data = null;
}

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;

  RealtimeChannel? _teamChannel;

  /// Khởi tạo kết nối Supabase và kiểm tra bảng CSDL
  Future<CloudResponse<bool>> initialize({required String url, required String anonKey}) async {
    try {
      if (url.trim().isEmpty || anonKey.trim().isEmpty) {
        return CloudResponse.failure('URL hoặc Anon Key không được để trống!');
      }

      final cleanUrl = url.trim();
      final cleanKey = anonKey.trim();

      if (!_isInitialized || !Supabase.instance.client.rest.url.toString().contains(cleanUrl)) {
        await Supabase.initialize(
          url: cleanUrl,
          anonKey: cleanKey,
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        );
        _isInitialized = true;
      }

      // THỬ TRUY VẤN THỰC TẾ ĐỂ KIỂM TRA BẢNG CSDL TRÊN SUPABASE
      try {
        await client!.from('teams').select('code').limit(1);
        return CloudResponse.success(true);
      } on PostgrestException catch (pe) {
        debugPrint('Supabase PostgrestException lúc test: ${pe.message} (${pe.code})');
        if (pe.code == '42P01' || pe.message.contains('does not exist')) {
          return CloudResponse.failure(
            'Kết nối tới Supabase thành công nhưng CSDL chưa có bảng "teams"!\n'
            '👉 Bạn cần vào mục "SQL Editor" trên Supabase, dán toàn bộ nội dung file "supabase_schema.sql" và bấm RUN.',
          );
        }
        return CloudResponse.failure('Lỗi phản hồi từ Supabase: ${pe.message} (Mã lỗi: ${pe.code})');
      } catch (err) {
        return CloudResponse.failure('Lỗi kiểm tra bảng CSDL Supabase: $err');
      }
    } catch (e) {
      debugPrint('Lỗi khởi tạo Supabase: $e');
      return CloudResponse.failure('Không thể khởi tạo kết nối Supabase: $e');
    }
  }

  // =================== QUẢN LÝ ĐỘI NHÓM (TEAMS) ===================

  /// Lấy thông tin nhóm bằng mã code
  Future<Team?> getTeam(String code) async {
    if (!_isInitialized) return null;
    try {
      final res = await client!
          .from('teams')
          .select()
          .eq('code', code.trim().toUpperCase())
          .maybeSingle();

      if (res != null) {
        return Team.fromMap(res);
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi lấy thông tin team: $e');
      return null;
    }
  }

  /// Tạo đội nhóm mới
  Future<CloudResponse<Team>> createTeam(String teamName, String ownerName) async {
    if (!_isInitialized) {
      return CloudResponse.failure('Chưa kết nối Supabase! Vui lòng lưu thông tin tại Tab 3 trước.');
    }
    try {
      final randomNum = Random().nextInt(9000) + 1000;
      final code = 'CSKB-$randomNum';

      final res = await client!.from('teams').insert({
        'code': code,
        'name': teamName.trim(),
        'owner_name': ownerName.trim(),
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final newTeam = Team.fromMap(res);

      // Thêm người tạo vào danh sách thành viên với quyền OWNER
      try {
        await client!.from('team_members').upsert({
          'team_code': code,
          'member_name': ownerName.trim(),
          'role': 'OWNER',
          'last_active': DateTime.now().toIso8601String(),
        }, onConflict: 'team_code, member_name');
      } catch (memberErr) {
        debugPrint('Cảnh báo lưu team_members: $memberErr');
      }

      return CloudResponse.success(newTeam);
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException tạo team: ${e.message} (code: ${e.code}, details: ${e.details})');
      if (e.code == '42P01' || e.message.contains('does not exist')) {
        return CloudResponse.failure(
          'Chưa tạo bảng CSDL trên Supabase!\n'
          '👉 Vui lòng vào Supabase Dashboard -> SQL Editor -> Dán nội dung file supabase_schema.sql và bấm RUN.',
        );
      }
      return CloudResponse.failure('Lỗi Supabase: ${e.message} (Mã: ${e.code})');
    } catch (e) {
      debugPrint('Lỗi tạo nhóm: $e');
      return CloudResponse.failure('Lỗi không xác định khi tạo nhóm: $e');
    }
  }

  /// Tham gia vào nhóm đã có
  Future<CloudResponse<bool>> joinTeam(String code, String memberName, {String role = 'MEMBER'}) async {
    if (!_isInitialized) {
      return CloudResponse.failure('Chưa kết nối Supabase! Vui lòng lưu thông tin tại Tab 3 trước.');
    }
    try {
      final team = await getTeam(code);
      if (team == null) {
        return CloudResponse.failure('Không tìm thấy nhóm có mã "${code.toUpperCase()}" trên máy chủ!');
      }

      await client!.from('team_members').upsert({
        'team_code': team.code,
        'member_name': memberName.trim(),
        'role': role,
        'last_active': DateTime.now().toIso8601String(),
      }, onConflict: 'team_code, member_name');

      return CloudResponse.success(true);
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException tham gia team: ${e.message}');
      return CloudResponse.failure('Lỗi Supabase: ${e.message}');
    } catch (e) {
      debugPrint('Lỗi tham gia nhóm: $e');
      return CloudResponse.failure('Lỗi tham gia nhóm: $e');
    }
  }

  /// Lấy danh sách thành viên nhóm
  Future<List<TeamMember>> getTeamMembers(String teamCode) async {
    if (!_isInitialized) return [];
    try {
      final res = await client!
          .from('team_members')
          .select()
          .eq('team_code', teamCode.trim().toUpperCase())
          .order('last_active', ascending: false);

      return (res as List).map((m) => TeamMember.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh sách thành viên: $e');
      return [];
    }
  }

  // =================== DỮ LIỆU ĐỒNG BỘ THEO NHÓM ===================

  /// Tải toàn bộ máy dò của nhóm
  Future<List<DetectorPurchase>> fetchDetectorPurchases(String teamCode) async {
    if (!_isInitialized) return [];
    try {
      final res = await client!
          .from('detector_purchases')
          .select()
          .eq('team_code', teamCode)
          .order('created_at', ascending: false);

      return (res as List).map((m) => DetectorPurchase.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Lỗi fetch detector_purchases: $e');
      return [];
    }
  }

  Future<void> insertDetectorPurchase(DetectorPurchase p, String teamCode, String createdBy) async {
    if (!_isInitialized) return;
    try {
      final map = p.toMap();
      map['team_code'] = teamCode;
      map['created_by'] = createdBy;
      await client!.from('detector_purchases').upsert(map);
    } catch (e) {
      debugPrint('Lỗi insert detector_purchases: $e');
    }
  }

  Future<void> deleteDetectorPurchase(String id) async {
    if (!_isInitialized) return;
    try {
      await client!.from('detector_purchases').delete().eq('id', id);
    } catch (e) {
      debugPrint('Lỗi delete detector_purchases: $e');
    }
  }

  /// Tải toàn bộ ca up của nhóm
  Future<List<FarmingSession>> fetchFarmingSessions(String teamCode) async {
    if (!_isInitialized) return [];
    try {
      final res = await client!
          .from('farming_sessions')
          .select()
          .eq('team_code', teamCode)
          .order('created_at', ascending: false);

      return (res as List).map((m) => FarmingSession.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Lỗi fetch farming_sessions: $e');
      return [];
    }
  }

  Future<void> insertFarmingSession(FarmingSession s, String teamCode, String createdBy) async {
    if (!_isInitialized) return;
    try {
      final map = s.toMap();
      map['team_code'] = teamCode;
      map['created_by'] = createdBy;
      await client!.from('farming_sessions').upsert(map);
    } catch (e) {
      debugPrint('Lỗi insert farming_sessions: $e');
    }
  }

  Future<void> deleteFarmingSession(String id) async {
    if (!_isInitialized) return;
    try {
      await client!.from('farming_sessions').delete().eq('id', id);
    } catch (e) {
      debugPrint('Lỗi delete farming_sessions: $e');
    }
  }

  /// Tải toàn bộ đơn bán hàng của nhóm
  Future<List<CskbSale>> fetchCskbSales(String teamCode) async {
    if (!_isInitialized) return [];
    try {
      final res = await client!
          .from('cskb_sales')
          .select()
          .eq('team_code', teamCode)
          .order('created_at', ascending: false);

      return (res as List).map((m) => CskbSale.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Lỗi fetch cskb_sales: $e');
      return [];
    }
  }

  Future<void> insertCskbSale(CskbSale sale, String teamCode, String createdBy) async {
    if (!_isInitialized) return;
    try {
      final map = sale.toMap();
      map['team_code'] = teamCode;
      map['created_by'] = createdBy;
      await client!.from('cskb_sales').upsert(map);
    } catch (e) {
      debugPrint('Lỗi insert cskb_sales: $e');
    }
  }

  Future<void> updateSaleStatus(String id, String newStatus) async {
    if (!_isInitialized) return;
    try {
      await client!.from('cskb_sales').update({'status': newStatus}).eq('id', id);
    } catch (e) {
      debugPrint('Lỗi updateSaleStatus: $e');
    }
  }

  Future<void> deleteCskbSale(String id) async {
    if (!_isInitialized) return;
    try {
      await client!.from('cskb_sales').delete().eq('id', id);
    } catch (e) {
      debugPrint('Lỗi delete cskb_sales: $e');
    }
  }

  /// Tải toàn bộ chi phí phụ
  Future<List<OtherExpense>> fetchOtherExpenses(String teamCode) async {
    if (!_isInitialized) return [];
    try {
      final res = await client!
          .from('other_expenses')
          .select()
          .eq('team_code', teamCode)
          .order('created_at', ascending: false);

      return (res as List).map((m) => OtherExpense.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Lỗi fetch other_expenses: $e');
      return [];
    }
  }

  Future<void> insertOtherExpense(OtherExpense exp, String teamCode, String createdBy) async {
    if (!_isInitialized) return;
    try {
      final map = exp.toMap();
      map['team_code'] = teamCode;
      map['created_by'] = createdBy;
      await client!.from('other_expenses').upsert(map);
    } catch (e) {
      debugPrint('Lỗi insert other_expenses: $e');
    }
  }

  Future<void> deleteOtherExpense(String id) async {
    if (!_isInitialized) return;
    try {
      await client!.from('other_expenses').delete().eq('id', id);
    } catch (e) {
      debugPrint('Lỗi delete other_expenses: $e');
    }
  }

  // =================== XUẤT DÙNG CSKB CÁ NHÂN ===================
  /// Tải toàn bộ lượt xuất dùng CSKB cá nhân của nhóm
  Future<List<CskbUsage>> fetchCskbUsages(String teamCode) async {
    if (!_isInitialized) return [];
    try {
      final res = await client!
          .from('cskb_usages')
          .select()
          .eq('team_code', teamCode)
          .order('created_at', ascending: false);

      return (res as List).map((m) => CskbUsage.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Lỗi fetch cskb_usages: $e');
      return [];
    }
  }

  Future<void> insertCskbUsage(CskbUsage usage, String teamCode, String createdBy) async {
    if (!_isInitialized) return;
    try {
      final map = usage.toMap();
      map['team_code'] = teamCode;
      map['created_by'] = createdBy;
      await client!.from('cskb_usages').upsert(map);
    } catch (e) {
      debugPrint('Lỗi insert cskb_usages: $e');
    }
  }

  Future<void> deleteCskbUsage(String id) async {
    if (!_isInitialized) return;
    try {
      await client!.from('cskb_usages').delete().eq('id', id);
    } catch (e) {
      debugPrint('Lỗi delete cskb_usages: $e');
    }
  }

  // =================== CÀI ĐẶT NHÓM ===================
  Future<String?> getTeamSetting(String teamCode, String key) async {
    if (!_isInitialized) return null;
    try {
      final res = await client!
          .from('team_settings')
          .select('value')
          .eq('team_code', teamCode)
          .eq('key', key)
          .maybeSingle();
      if (res != null) {
        return res['value'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setTeamSetting(String teamCode, String key, String value) async {
    if (!_isInitialized) return;
    try {
      await client!.from('team_settings').upsert({
        'team_code': teamCode,
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Lỗi setTeamSetting: $e');
    }
  }

  // =================== REALTIME LẮNG NGHE ĐỒNG BỘ TỨC THÌ ===================
  void subscribeToTeamChanges(String teamCode, VoidCallback onDataChanged) {
    if (!_isInitialized) return;

    unsubscribe();

    _teamChannel = client!.channel('team-$teamCode');
    _teamChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'detector_purchases',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'team_code',
            value: teamCode,
          ),
          callback: (payload) => onDataChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'farming_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'team_code',
            value: teamCode,
          ),
          callback: (payload) => onDataChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cskb_sales',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'team_code',
            value: teamCode,
          ),
          callback: (payload) => onDataChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'other_expenses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'team_code',
            value: teamCode,
          ),
          callback: (payload) => onDataChanged(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'team_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'team_code',
            value: teamCode,
          ),
          callback: (payload) => onDataChanged(),
        )
        .subscribe();
  }

  void unsubscribe() {
    if (_teamChannel != null) {
      _teamChannel!.unsubscribe();
      _teamChannel = null;
    }
  }
}
