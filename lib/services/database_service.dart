import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/database/app_database.dart';
import '../models/detector_purchase.dart';
import '../models/farming_session.dart';
import '../models/cskb_sale.dart';
import '../models/other_expense.dart';

class DatabaseService {
  final AppDatabase _dbProvider = AppDatabase.instance;

  // =================== MÁY DÒ (DETECTOR) ===================
  Future<void> insertDetectorPurchase(DetectorPurchase purchase) async {
    final db = await _dbProvider.database;
    await db.insert(
      'detector_purchases',
      purchase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DetectorPurchase>> getAllDetectorPurchases() async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'detector_purchases',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => DetectorPurchase.fromMap(map)).toList();
  }

  Future<void> deleteDetectorPurchase(String id) async {
    final db = await _dbProvider.database;
    await db.delete('detector_purchases', where: 'id = ?', whereArgs: [id]);
  }

  // =================== CA UP CSKB (FARMING) ===================
  Future<void> insertFarmingSession(FarmingSession session) async {
    final db = await _dbProvider.database;
    await db.insert(
      'farming_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FarmingSession>> getAllFarmingSessions() async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'farming_sessions',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => FarmingSession.fromMap(map)).toList();
  }

  Future<void> deleteFarmingSession(String id) async {
    final db = await _dbProvider.database;
    await db.delete('farming_sessions', where: 'id = ?', whereArgs: [id]);
  }

  // =================== BÁN HÀNG (SALES) ===================
  Future<void> insertCskbSale(CskbSale sale) async {
    final db = await _dbProvider.database;
    await db.insert(
      'cskb_sales',
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CskbSale>> getAllCskbSales() async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'cskb_sales',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => CskbSale.fromMap(map)).toList();
  }

  Future<void> updateSaleStatus(String id, String newStatus) async {
    final db = await _dbProvider.database;
    await db.update(
      'cskb_sales',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCskbSale(String id) async {
    final db = await _dbProvider.database;
    await db.delete('cskb_sales', where: 'id = ?', whereArgs: [id]);
  }

  // =================== CHI PHÍ PHỤ (EXPENSES) ===================
  Future<void> insertOtherExpense(OtherExpense expense) async {
    final db = await _dbProvider.database;
    await db.insert(
      'other_expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OtherExpense>> getAllOtherExpenses() async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'other_expenses',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => OtherExpense.fromMap(map)).toList();
  }

  Future<void> deleteOtherExpense(String id) async {
    final db = await _dbProvider.database;
    await db.delete('other_expenses', where: 'id = ?', whereArgs: [id]);
  }

  // =================== CÀI ĐẶT (SETTINGS) ===================
  Future<String?> getSetting(String key) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _dbProvider.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
