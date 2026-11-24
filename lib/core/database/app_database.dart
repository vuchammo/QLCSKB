import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('qlcskb_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Khởi tạo FFI cho môi trường Desktop (Windows, macOS, Linux)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(dbDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Bảng Nhập máy dò
    await db.execute('''
      CREATE TABLE detector_purchases (
        id TEXT PRIMARY KEY,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        currency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        note TEXT
      )
    ''');

    // 2. Bảng Ca Treo Up CSKB
    await db.execute('''
      CREATE TABLE farming_sessions (
        id TEXT PRIMARY KEY,
        detectors_used INTEGER NOT NULL,
        cskb_collected INTEGER NOT NULL,
        server TEXT NOT NULL,
        account_name TEXT,
        created_at TEXT NOT NULL,
        note TEXT
      )
    ''');

    // 3. Bảng Đơn bán CSKB
    await db.execute('''
      CREATE TABLE cskb_sales (
        id TEXT PRIMARY KEY,
        pack_count INTEGER NOT NULL,
        loose_count INTEGER NOT NULL DEFAULT 0,
        unit_price_per_pack REAL NOT NULL,
        total_revenue REAL NOT NULL,
        currency TEXT NOT NULL,
        customer_name TEXT,
        server TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'PAID',
        note TEXT
      )
    ''');

    // 4. Bảng Chi phí phụ
    await db.execute('''
      CREATE TABLE other_expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        note TEXT
      )
    ''');

    // 5. Bảng Cài đặt
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Cài đặt mặc định
    await db.insert('settings', {
      'key': AppConstants.settingExchangeRateTvToVnd,
      'value': AppConstants.defaultTvToVndRate.toString(),
    });
    await db.insert('settings', {
      'key': AppConstants.settingDefaultCurrency,
      'value': AppConstants.currencyVnd,
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
