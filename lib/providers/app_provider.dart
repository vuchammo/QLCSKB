import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/detector_purchase.dart';
import '../models/farming_session.dart';
import '../models/cskb_sale.dart';
import '../models/other_expense.dart';
import '../models/profit_loss_summary.dart';
import '../services/database_service.dart';
import '../services/calculation_service.dart';

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

  List<DetectorPurchase> _detectorPurchases = [];
  List<FarmingSession> _farmingSessions = [];
  List<CskbSale> _cskbSales = [];
  List<OtherExpense> _otherExpenses = [];

  double _exchangeRateTvToVnd = AppConstants.defaultTvToVndRate;
  String _defaultCurrency = AppConstants.currencyVnd;
  bool _isLoading = true;

  DateFilterMode _dateFilterMode = DateFilterMode.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Getters
  bool get isLoading => _isLoading;
  List<DetectorPurchase> get detectorPurchases => _detectorPurchases;
  List<FarmingSession> get farmingSessions => _farmingSessions;
  List<CskbSale> get cskbSales => _cskbSales;
  List<OtherExpense> get otherExpenses => _otherExpenses;
  double get exchangeRateTvToVnd => _exchangeRateTvToVnd;
  String get defaultCurrency => _defaultCurrency;
  DateFilterMode get dateFilterMode => _dateFilterMode;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  // Summary được tính toán tự động
  ProfitLossSummary get summary {
    final range = _getDateRange();
    return CalculationService.calculateSummary(
      purchases: _detectorPurchases,
      sessions: _farmingSessions,
      sales: _cskbSales,
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
      _detectorPurchases = await _dbService.getAllDetectorPurchases();
      _farmingSessions = await _dbService.getAllFarmingSessions();
      _cskbSales = await _dbService.getAllCskbSales();
      _otherExpenses = await _dbService.getAllOtherExpenses();

      final rateStr = await _dbService.getSetting(AppConstants.settingExchangeRateTvToVnd);
      if (rateStr != null) {
        _exchangeRateTvToVnd = double.tryParse(rateStr) ?? AppConstants.defaultTvToVndRate;
      }

      final curr = await _dbService.getSetting(AppConstants.settingDefaultCurrency);
      if (curr != null) {
        _defaultCurrency = curr;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== MÁY DÒ ===================
  Future<void> addDetectorPurchase(DetectorPurchase purchase) async {
    await _dbService.insertDetectorPurchase(purchase);
    _detectorPurchases = await _dbService.getAllDetectorPurchases();
    notifyListeners();
  }

  Future<void> deleteDetectorPurchase(String id) async {
    await _dbService.deleteDetectorPurchase(id);
    _detectorPurchases = await _dbService.getAllDetectorPurchases();
    notifyListeners();
  }

  // =================== CA UP CSKB ===================
  Future<void> addFarmingSession(FarmingSession session) async {
    await _dbService.insertFarmingSession(session);
    _farmingSessions = await _dbService.getAllFarmingSessions();
    notifyListeners();
  }

  Future<void> deleteFarmingSession(String id) async {
    await _dbService.deleteFarmingSession(id);
    _farmingSessions = await _dbService.getAllFarmingSessions();
    notifyListeners();
  }

  // =================== ĐƠN BÁN CSKB ===================
  Future<void> addCskbSale(CskbSale sale) async {
    await _dbService.insertCskbSale(sale);
    _cskbSales = await _dbService.getAllCskbSales();
    notifyListeners();
  }

  Future<void> toggleSaleStatus(String id) async {
    final sale = _cskbSales.firstWhere((s) => s.id == id);
    final newStatus = sale.isPaid ? 'DEBT' : 'PAID';
    await _dbService.updateSaleStatus(id, newStatus);
    _cskbSales = await _dbService.getAllCskbSales();
    notifyListeners();
  }

  Future<void> deleteCskbSale(String id) async {
    await _dbService.deleteCskbSale(id);
    _cskbSales = await _dbService.getAllCskbSales();
    notifyListeners();
  }

  // =================== CHI PHÍ KHÁC ===================
  Future<void> addOtherExpense(OtherExpense expense) async {
    await _dbService.insertOtherExpense(expense);
    _otherExpenses = await _dbService.getAllOtherExpenses();
    notifyListeners();
  }

  Future<void> deleteOtherExpense(String id) async {
    await _dbService.deleteOtherExpense(id);
    _otherExpenses = await _dbService.getAllOtherExpenses();
    notifyListeners();
  }

  // =================== CÀI ĐẶT & LỌC ===================
  Future<void> updateExchangeRate(double rate) async {
    _exchangeRateTvToVnd = rate;
    await _dbService.setSetting(AppConstants.settingExchangeRateTvToVnd, rate.toString());
    notifyListeners();
  }

  void setDateFilter(DateFilterMode mode, {DateTime? start, DateTime? end}) {
    _dateFilterMode = mode;
    _customStartDate = start;
    _customEndDate = end;
    notifyListeners();
  }
}
