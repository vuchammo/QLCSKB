import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qlcskb/models/cskb_usage.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Simulate upgrading version 1 DB to version 2 DB', () async {
    final tempDir = Directory.systemTemp.createTempSync('db_test');
    final dbPath = '${tempDir.path}/test_v1_to_v2.db';

    // 1. Tạo DB version 1 giống như DB trước đây
    final dbV1 = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
    await dbV1.close();

    // 2. Mở DB với version 2
    final dbV2 = await openDatabase(
      dbPath,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cskb_usages (
              id TEXT PRIMARY KEY,
              pack_count INTEGER NOT NULL DEFAULT 0,
              loose_count INTEGER NOT NULL DEFAULT 0,
              purpose TEXT NOT NULL,
              character_name TEXT,
              server TEXT NOT NULL DEFAULT 'Vũ trụ 1',
              created_at TEXT NOT NULL,
              note TEXT
            )
          ''');
        }
      },
    );

    final usage = CskbUsage(
      id: 'upgrade-test-1',
      packCount: 2,
      looseCount: 10,
      purpose: 'Mở Đồ sao',
      createdAt: DateTime.now(),
    );

    await dbV2.insert('cskb_usages', usage.toMap());
    final list = await dbV2.query('cskb_usages');
    expect(list.length, 1);
    await dbV2.close();
    tempDir.deleteSync(recursive: true);
  });
}
