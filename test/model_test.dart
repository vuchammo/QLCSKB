import 'package:flutter_test/flutter_test.dart';
import 'package:qlcskb/models/detector_purchase.dart';
import 'package:qlcskb/models/farming_session.dart';
import 'package:qlcskb/models/cskb_sale.dart';
import 'package:qlcskb/models/cskb_usage.dart';
import 'package:qlcskb/models/other_expense.dart';

void main() {
  group('Data Models Tests', () {
    test('DetectorPurchase model serialization & unit price', () {
      final purchase = DetectorPurchase(
        id: 'test-id',
        quantity: 100,
        totalPrice: 150000.0,
        currency: 'VND',
        createdAt: DateTime.parse('2026-11-24T08:00:00.000'),
        note: 'Mua NPC Bunma',
      );

      expect(purchase.unitPrice, 1500.0);
      final map = purchase.toMap();
      final fromMap = DetectorPurchase.fromMap(map);

      expect(fromMap.id, purchase.id);
      expect(fromMap.quantity, purchase.quantity);
      expect(fromMap.totalPrice, purchase.totalPrice);
      expect(fromMap.currency, purchase.currency);
      expect(fromMap.note, purchase.note);
    });

    test('FarmingSession drop rate & serialization', () {
      final session = FarmingSession(
        id: 'session-id',
        detectorsUsed: 20,
        cskbCollected: 520,
        server: 'Vũ trụ 1',
        accountName: 'GokuSSJ',
        createdAt: DateTime.now(),
        note: 'Map Đông Karin',
      );

      expect(session.dropRate, 26.0);
      final map = session.toMap();
      final fromMap = FarmingSession.fromMap(map);

      expect(fromMap.detectorsUsed, 20);
      expect(fromMap.cskbCollected, 520);
      expect(fromMap.dropRate, 26.0);
    });

    test('CskbSale totalCskb calculation & status', () {
      final sale = CskbSale(
        id: 'sale-1',
        packCount: 3,
        looseCount: 15,
        unitPricePerPack: 40000.0,
        totalRevenue: 120600.0,
        currency: 'VND',
        createdAt: DateTime.now(),
        status: 'PAID',
      );

      expect(sale.totalCskb, (3 * 999) + 15);
      expect(sale.isPaid, true);
    });

    test('OtherExpense model serialization', () {
      final exp = OtherExpense(
        id: 'exp-1',
        title: 'Bùa dẻo dai',
        amount: 25000.0,
        currency: 'VND',
        createdAt: DateTime.now(),
      );

      final map = exp.toMap();
      final fromMap = OtherExpense.fromMap(map);
      expect(fromMap.title, 'Bùa dẻo dai');
      expect(fromMap.amount, 25000.0);
    });

    test('CskbUsage model serialization & totalCskb calculation', () {
      final usage = CskbUsage(
        id: 'usage-1',
        packCount: 2,
        looseCount: 50,
        purpose: 'Mở Cải trang Dracula',
        characterName: 'GokuSSJ',
        server: 'Vũ trụ 1',
        createdAt: DateTime.parse('2026-11-24T10:00:00.000'),
        note: 'Mở ra Cải trang Dracula 30 ngày',
      );

      expect(usage.totalCskb, (2 * 999) + 50);
      final map = usage.toMap();
      final fromMap = CskbUsage.fromMap(map);

      expect(fromMap.id, 'usage-1');
      expect(fromMap.packCount, 2);
      expect(fromMap.looseCount, 50);
      expect(fromMap.totalCskb, (2 * 999) + 50);
      expect(fromMap.purpose, 'Mở Cải trang Dracula');
      expect(fromMap.characterName, 'GokuSSJ');
      expect(fromMap.note, 'Mở ra Cải trang Dracula 30 ngày');
    });
  });
}
