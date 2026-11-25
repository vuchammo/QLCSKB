import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/detector_purchase.dart';
import '../models/farming_session.dart';
import '../models/cskb_sale.dart';
import '../models/cskb_usage.dart';
import '../models/other_expense.dart';
import '../models/profit_loss_summary.dart';
import '../models/team_model.dart';
import '../services/database_service.dart';
import '../services/calculation_service.dart';
import '../services/supabase_service.dart';

enum DateFilterMode {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  custom,
}

class AppProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final SupabaseService _supabase = SupabaseService.instance;

  List<DetectorPurchase> _detectorPurchases = [];
  List<FarmingSession> _farmingSessions = [];
  List<CskbSale> _cskbSales = [];
  List<CskbUsage> _cskbUsages = [];
  List<OtherExpense> _otherExpenses = [];

  double _exchangeRateTvToVnd = AppConstants.defaultTvToVndRate;
  String _defaultCurrency = AppConstants.currencyVnd;
  String _defaultServer = AppConstants.defaultServer;
  bool _isLoading = true;

  // Trạng thái Cloud & Đội nhóm
  String? _currentTeamCode;
  String? _currentTeamName;
  String _memberName = 'Dân cày NRO';
  String _supabaseUrl = '';
  String _supabaseAnonKey = '';
  List<TeamMember> _teamMembers = [];

  DateFilterMode _dateFilterMode = DateFilterMode.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Getters
  bool get isLoading => _isLoading;
  List<DetectorPurchase> get detectorPurchases => _detectorPurchases;
  List<FarmingSession> get farmingSessions => _farmingSessions;
  List<CskbSale> get cskbSales => _cskbSales;
  List<CskbUsage> get cskbUsages => _cskbUsages;
  List<OtherExpense> get otherExpenses => _otherExpenses;
  double get exchangeRateTvToVnd => _exchangeRateTvToVnd;
  String get defaultCurrency => _defaultCurrency;
  String get defaultServer => _defaultServer;
  DateFilterMode get dateFilterMode => _dateFilterMode;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  // Getters Cloud & Đội nhóm
  bool get isOnlineMode => _currentTeamCode != null && _currentTeamCode!.isNotEmpty;
  String? get currentTeamCode => _currentTeamCode;
  String? get currentTeamName => _currentTeamName;
  String get memberName => _memberName;
  String get supabaseUrl => _supabaseUrl;
  String get supabaseAnonKey => _supabaseAnonKey;
  List<TeamMember> get teamMembers => _teamMembers;

  // Summary được tính toán tự động
  ProfitLossSummary get summary {
    final range = _getDateRange();
    return CalculationService.calculateSummary(
      purchases: _detectorPurchases,
      sessions: _farmingSessions,
      sales: _cskbSales,
      usages: _cskbUsages,
      expenses: _otherExpenses,
      exchangeRateTvToVnd: _exchangeRateTvToVnd,
      startDate: range.$1,
      endDate: range.$2,
    );
  }

  (DateTime?, DateTime?) _getDateRange() {
    final now = DateTime.now();
    switch (_dateFilterMode) {
      case DateFilterMode.all:
        return (null, null);
      case DateFilterMode.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (start, end);
      case DateFilterMode.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        return (start, end);
      case DateFilterMode.thisWeek:
        final start = now.subtract(const Duration(days: 7));
        return (start, now);
      case DateFilterMode.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        return (start, now);
      case DateFilterMode.custom:
        return (_customStartDate, _customEndDate);
    }
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Tải cài đặt cục bộ
      final rateStr = await _dbService.getSetting(AppConstants.settingExchangeRateTvToVnd);
      if (rateStr != null) {
        _exchangeRateTvToVnd = double.tryParse(rateStr) ?? AppConstants.defaultTvToVndRate;
      }

      final curr = await _dbService.getSetting(AppConstants.settingDefaultCurrency);
      if (curr != null) {
        _defaultCurrency = curr;
      }

      final server = await _dbService.getSetting(AppConstants.settingDefaultServer);
      if (server != null && server.isNotEmpty) {
        _defaultServer = server;
      }

      final url = await _dbService.getSetting(AppConstants.settingSupabaseUrl);
      final key = await _dbService.getSetting(AppConstants.settingSupabaseAnonKey);
      _supabaseUrl = url ?? '';
      _supabaseAnonKey = key ?? '';

      final teamCode = await _dbService.getSetting(AppConstants.settingCurrentTeamCode);
      final teamName = await _dbService.getSetting(AppConstants.settingCurrentTeamName);
      final member = await _dbService.getSetting(AppConstants.settingMemberName);

      _currentTeamCode = teamCode;
      _currentTeamName = teamName;
      if (member != null && member.isNotEmpty) {
        _memberName = member;
      }

      // 2. Nếu có cấu hình Supabase và đang ở chế độ nhóm
      if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
        final initRes = await _supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

        if (initRes.success && _currentTeamCode != null && _currentTeamCode!.isNotEmpty) {
          await _refreshOnlineTeamData();
          _setupRealtimeSync();
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 3. Mặc định tải từ CSDL SQLite cục bộ (Offline)
      await _loadLocalData();
    } catch (e) {
      debugPrint('Error loading data: $e');
      await _loadLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLocalData() async {
    _detectorPurchases = await _dbService.getAllDetectorPurchases();
    _farmingSessions = await _dbService.getAllFarmingSessions();
    _cskbSales = await _dbService.getAllCskbSales();
    _cskbUsages = await _dbService.getAllCskbUsages();
    _otherExpenses = await _dbService.getAllOtherExpenses();
  }

  Future<void> _refreshOnlineTeamData() async {
    if (_currentTeamCode == null || _currentTeamCode!.isEmpty) return;
    try {
      _detectorPurchases = await _supabase.fetchDetectorPurchases(_currentTeamCode!);
      _farmingSessions = await _supabase.fetchFarmingSessions(_currentTeamCode!);
      _cskbSales = await _supabase.fetchCskbSales(_currentTeamCode!);

      final cloudUsages = await _supabase.fetchCskbUsages(_currentTeamCode!);
      final localUsages = await _dbService.getAllCskbUsages();
      if (cloudUsages.isNotEmpty) {
        final Map<String, CskbUsage> map = {
          for (var u in localUsages) u.id: u,
          for (var u in cloudUsages) u.id: u,
        };
        _cskbUsages = map.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _cskbUsages = localUsages;
      }

      _otherExpenses = await _supabase.fetchOtherExpenses(_currentTeamCode!);
      _teamMembers = await _supabase.getTeamMembers(_currentTeamCode!);

      final cloudRate = await _supabase.getTeamSetting(_currentTeamCode!, AppConstants.settingExchangeRateTvToVnd);
      if (cloudRate != null) {
        _exchangeRateTvToVnd = double.tryParse(cloudRate) ?? _exchangeRateTvToVnd;
      }
    } catch (e) {
      debugPrint('Error refreshing online team data: $e');
    }
  }

  void _setupRealtimeSync() {
    if (_currentTeamCode == null || _currentTeamCode!.isEmpty) return;
    _supabase.subscribeToTeamChanges(_currentTeamCode!, () async {
      debugPrint('Nhận tín hiệu đồng bộ Realtime từ thiết bị khác!');
      await _refreshOnlineTeamData();
      notifyListeners();
    });
  }

  // =================== QUẢN LÝ ĐỘI NHÓM & CLOUD ===================

  Future<CloudResponse<bool>> connectSupabase(String url, String anonKey) async {
    final response = await _supabase.initialize(url: url, anonKey: anonKey);
    if (response.success) {
      _supabaseUrl = url;
      _supabaseAnonKey = anonKey;
      await _dbService.setSetting(AppConstants.settingSupabaseUrl, url);
      await _dbService.setSetting(AppConstants.settingSupabaseAnonKey, anonKey);
      notifyListeners();
    }
    return response;
  }

  Future<CloudResponse<Team>> createTeamOnline(String teamName, String ownerName) async {
    final response = await _supabase.createTeam(teamName, ownerName);
    if (response.success && response.data != null) {
      final team = response.data!;
      _currentTeamCode = team.code;
      _currentTeamName = team.name;
      _memberName = ownerName;

      await _dbService.setSetting(AppConstants.settingCurrentTeamCode, team.code);
      await _dbService.setSetting(AppConstants.settingCurrentTeamName, team.name);
      await _dbService.setSetting(AppConstants.settingMemberName, ownerName);

      await _refreshOnlineTeamData();
      _setupRealtimeSync();
      notifyListeners();
    }
    return response;
  }

  Future<CloudResponse<bool>> joinTeamOnline(String teamCode, String memberName, {String role = 'MEMBER'}) async {
    final response = await _supabase.joinTeam(teamCode, memberName, role: role);
    if (response.success) {
      final team = await _supabase.getTeam(teamCode);
      _currentTeamCode = team?.code ?? teamCode;
      _currentTeamName = team?.name ?? 'Nhóm $teamCode';
      _memberName = memberName;

      await _dbService.setSetting(AppConstants.settingCurrentTeamCode, _currentTeamCode!);
      await _dbService.setSetting(AppConstants.settingCurrentTeamName, _currentTeamName!);
      await _dbService.setSetting(AppConstants.settingMemberName, memberName);

      await _refreshOnlineTeamData();
      _setupRealtimeSync();
      notifyListeners();
    }
    return response;
  }

  Future<void> leaveTeamOnline() async {
    _supabase.unsubscribe();
    _currentTeamCode = null;
    _currentTeamName = null;
    await _dbService.setSetting(AppConstants.settingCurrentTeamCode, '');
    await _dbService.setSetting(AppConstants.settingCurrentTeamName, '');

    await _loadLocalData();
    notifyListeners();
  }

  // =================== MÁY DÒ ===================
  Future<void> addDetectorPurchase(DetectorPurchase purchase) async {
    await _dbService.insertDetectorPurchase(purchase);

    if (isOnlineMode) {
      await _supabase.insertDetectorPurchase(purchase, _currentTeamCode!, _memberName);
      await _refreshOnlineTeamData();
    } else {
      _detectorPurchases = await _dbService.getAllDetectorPurchases();
    }
    notifyListeners();
  }

  Future<void> deleteDetectorPurchase(String id) async {
    await _dbService.deleteDetectorPurchase(id);

    if (isOnlineMode) {
      await _supabase.deleteDetectorPurchase(id);
      await _refreshOnlineTeamData();
    } else {
      _detectorPurchases = await _dbService.getAllDetectorPurchases();
    }
    notifyListeners();
  }

  // =================== CA UP CSKB ===================
  Future<void> addFarmingSession(FarmingSession session) async {
    await _dbService.insertFarmingSession(session);

    if (isOnlineMode) {
      await _supabase.insertFarmingSession(session, _currentTeamCode!, _memberName);
      await _refreshOnlineTeamData();
    } else {
      _farmingSessions = await _dbService.getAllFarmingSessions();
    }
    notifyListeners();
  }

  Future<void> deleteFarmingSession(String id) async {
    await _dbService.deleteFarmingSession(id);

    if (isOnlineMode) {
      await _supabase.deleteFarmingSession(id);
      await _refreshOnlineTeamData();
    } else {
      _farmingSessions = await _dbService.getAllFarmingSessions();
    }
    notifyListeners();
  }

  // =================== ĐƠN BÁN CSKB ===================
  Future<void> addCskbSale(CskbSale sale) async {
    await _dbService.insertCskbSale(sale);

    if (isOnlineMode) {
      await _supabase.insertCskbSale(sale, _currentTeamCode!, _memberName);
      await _refreshOnlineTeamData();
    } else {
      _cskbSales = await _dbService.getAllCskbSales();
    }
    notifyListeners();
  }

  Future<void> toggleSaleStatus(String id) async {
    final sale = _cskbSales.firstWhere((s) => s.id == id);
    final newStatus = sale.isPaid ? 'DEBT' : 'PAID';
    await _dbService.updateSaleStatus(id, newStatus);

    if (isOnlineMode) {
      await _supabase.updateSaleStatus(id, newStatus);
      await _refreshOnlineTeamData();
    } else {
      _cskbSales = await _dbService.getAllCskbSales();
    }
    notifyListeners();
  }

  Future<void> deleteCskbSale(String id) async {
    await _dbService.deleteCskbSale(id);

    if (isOnlineMode) {
      await _supabase.deleteCskbSale(id);
      await _refreshOnlineTeamData();
    } else {
      _cskbSales = await _dbService.getAllCskbSales();
    }
    notifyListeners();
  }

  // =================== XUẤT DÙNG CSKB CHO CÁ NHÂN ===================
  Future<void> addCskbUsage(CskbUsage usage) async {
    // Luôn lưu trữ SQLite offline trước
    await _dbService.insertCskbUsage(usage);
    _cskbUsages = await _dbService.getAllCskbUsages();
    notifyListeners();

    // Nếu đang ở chế độ nhóm Online, đồng bộ lên Cloud
    if (isOnlineMode) {
      try {
        await _supabase.insertCskbUsage(usage, _currentTeamCode!, _memberName);
        final cloudUsages = await _supabase.fetchCskbUsages(_currentTeamCode!);
        if (cloudUsages.isNotEmpty) {
          final Map<String, CskbUsage> map = {
            for (var u in _cskbUsages) u.id: u,
            for (var u in cloudUsages) u.id: u,
          };
          _cskbUsages = map.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Lỗi insertCskbUsage online: $e');
      }
    }
  }

  Future<void> deleteCskbUsage(String id) async {
    await _dbService.deleteCskbUsage(id);
    _cskbUsages.removeWhere((u) => u.id == id);
    notifyListeners();

    if (isOnlineMode) {
      try {
        await _supabase.deleteCskbUsage(id);
      } catch (e) {
        debugPrint('Lỗi deleteCskbUsage online: $e');
      }
    }
  }

  // =================== CHI PHÍ KHÁC ===================
  Future<void> addOtherExpense(OtherExpense expense) async {
    await _dbService.insertOtherExpense(expense);

    if (isOnlineMode) {
      await _supabase.insertOtherExpense(expense, _currentTeamCode!, _memberName);
      await _refreshOnlineTeamData();
    } else {
      _otherExpenses = await _dbService.getAllOtherExpenses();
    }
    notifyListeners();
  }

  Future<void> deleteOtherExpense(String id) async {
    await _dbService.deleteOtherExpense(id);

    if (isOnlineMode) {
      await _supabase.deleteOtherExpense(id);
      await _refreshOnlineTeamData();
    } else {
      _otherExpenses = await _dbService.getAllOtherExpenses();
    }
    notifyListeners();
  }

  // =================== CÀI ĐẶT & LỌC ===================
  Future<void> updateDefaultServer(String server) async {
    _defaultServer = server;
    await _dbService.setSetting(AppConstants.settingDefaultServer, server);
    notifyListeners();
  }

  Future<void> updateExchangeRate(double rate) async {
    _exchangeRateTvToVnd = rate;
    await _dbService.setSetting(AppConstants.settingExchangeRateTvToVnd, rate.toString());

    if (isOnlineMode) {
      await _supabase.setTeamSetting(_currentTeamCode!, AppConstants.settingExchangeRateTvToVnd, rate.toString());
    }
    notifyListeners();
  }

  void setDateFilter(DateFilterMode mode, {DateTime? start, DateTime? end}) {
    _dateFilterMode = mode;
    _customStartDate = start;
    _customEndDate = end;
    notifyListeners();
  }
}
