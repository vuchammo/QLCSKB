import 'package:flutter_test/flutter_test.dart';
import 'package:qlcskb/core/constants/app_constants.dart';
import 'package:qlcskb/models/detector_purchase.dart';
import 'package:qlcskb/models/farming_session.dart';
import 'package:qlcskb/models/cskb_sale.dart';
import 'package:qlcskb/models/cskb_usage.dart';
import 'package:qlcskb/models/other_expense.dart';
import 'package:qlcskb/services/calculation_service.dart';

void main() {
  group('CalculationService - Quy đổi gói x999 CSKB', () {
    test('cskbToPacks: Quy đổi chính xác số gói x999', () {
      expect(CalculationService.cskbToPacks(0), 0);
      expect(CalculationService.cskbToPacks(500), 0);
      expect(CalculationService.cskbToPacks(998), 0);
      expect(CalculationService.cskbToPacks(999), 1);
      expect(CalculationService.cskbToPacks(1000), 1);
      expect(CalculationService.cskbToPacks(1998), 2);
      expect(CalculationService.cskbToPacks(2500), 2);
      expect(CalculationService.cskbToPacks(9990), 10);
    });

    test('cskbToLoose: Tính chính xác số lượng viên lẻ dư', () {
      expect(CalculationService.cskbToLoose(0), 0);
      expect(CalculationService.cskbToLoose(500), 500);
      expect(CalculationService.cskbToLoose(998), 998);
      expect(CalculationService.cskbToLoose(999), 0);
      expect(CalculationService.cskbToLoose(1000), 1);
      expect(CalculationService.cskbToLoose(2500), 502); // 2500 - 2 * 999 = 502
    });

    test('packsAndLooseToCskb: Ghép gói và viên lẻ thành tổng CSKB', () {
      expect(CalculationService.packsAndLooseToCskb(0, 0), 0);
      expect(CalculationService.packsAndLooseToCskb(1, 0), 999);
      expect(CalculationService.packsAndLooseToCskb(2, 502), 2500);
      expect(CalculationService.packsAndLooseToCskb(5, 10), (5 * 999) + 10);
    });
  });

  group('CalculationService - Báo cáo Lời Lỗ và Tài chính (P&L)', () {
    test('calculateSummary: Tính toán chính xác doanh thu, giá vốn, tồn kho và lợi nhuận ròng', () {
      final now = DateTime.now();

      // 1. Mua 200 máy dò với tổng tiền 200,000 VND (1,000 VND / cái)
      final purchases = [
        DetectorPurchase(
          id: 'p1',
          quantity: 200,
          totalPrice: 200000.0,
          currency: AppConstants.currencyVnd,
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      ];

      // 2. Hai ca up: Dùng 100 máy dò -> Thu được 2,500 viên CSKB
      final sessions = [
        FarmingSession(
          id: 's1',
          detectorsUsed: 50,
          cskbCollected: 1250,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        FarmingSession(
          id: 's2',
          detectorsUsed: 50,
          cskbCollected: 1250,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      // 3. Đơn bán: Bán 2 gói x999 (1,998 viên CSKB) với giá 50,000 VND/gói = 100,000 VND
      final sales = [
        CskbSale(
          id: 'sale1',
          packCount: 2,
          looseCount: 0,
          unitPricePerPack: 50000.0,
          totalRevenue: 100000.0,
          currency: AppConstants.currencyVnd,
          createdAt: now,
        ),
      ];

      // 4. Chi phí phụ (bùa thu hút): 5,000 VND
      final expenses = [
        OtherExpense(
          id: 'e1',
          title: 'Bùa thu hút',
          amount: 5000.0,
          currency: AppConstants.currencyVnd,
          createdAt: now,
        ),
      ];

      final summary = CalculationService.calculateSummary(
        purchases: purchases,
        sessions: sessions,
        sales: sales,
        expenses: expenses,
        exchangeRateTvToVnd: 350.0,
      );

      // Kiểm tra Tồn kho máy dò: 200 mua - 100 dùng = 100 cái
      expect(summary.totalDetectorsPurchased, 200);
      expect(summary.totalDetectorsUsed, 100);
      expect(summary.currentDetectorStock, 100);

      // Kiểm tra Tỷ lệ rơi (Drop Rate): 2500 CSKB / 100 máy dò = 25.0 viên/máy
      expect(summary.averageDropRate, 25.0);

      // Kiểm tra Tồn kho CSKB: 2500 thu hoạch - 1998 bán = 502 viên
      expect(summary.totalCskbCollected, 2500);
      expect(summary.totalCskbSold, 1998);
      expect(summary.currentCskbStock, 502);
      expect(summary.stockPacks, 0);
      expect(summary.stockLoose, 502);

      // Kiểm tra Doanh thu
      expect(summary.totalRevenueVnd, 100000.0);

      // Kiểm tra Giá vốn (COGS):
      // 100 máy dò dùng tốn 100,000 VND -> Giá vốn 1 viên CSKB = 100,000 / 2,500 = 40 VND
      // Đã bán 1,998 viên -> COGS = 1,998 * 40 = 79,920 VND
      expect(summary.cogsVnd, closeTo(79920.0, 0.01));

      // Kiểm tra Lợi nhuận ròng:
      // Net Profit = 100,000 (Doanh thu) - 79,920 (COGS) - 5,000 (Chi phí phụ) = 15,080 VND
      expect(summary.netProfitVnd, closeTo(15080.0, 0.01));

      // Kiểm tra ROI %: 15,080 / (79,920 + 5,000) * 100 = 17.76%
      expect(summary.roiVnd, closeTo(17.76, 0.1));
    });

    test('calculateSummary: Tính toán chính xác khi xuất dùng CSKB cho cá nhân', () {
      final now = DateTime.now();

      // Mua 100 máy dò = 100,000 VND (1,000 đ/cái)
      final purchases = [
        DetectorPurchase(
          id: 'p1',
          quantity: 100,
          totalPrice: 100000.0,
          currency: AppConstants.currencyVnd,
          createdAt: now,
        ),
      ];

      // Dùng 100 máy dò thu về 3,000 viên CSKB (Giá vốn 1 viên = 100,000 / 3000 = 33.333 đ)
      final sessions = [
        FarmingSession(
          id: 's1',
          detectorsUsed: 100,
          cskbCollected: 3000,
          createdAt: now,
        ),
      ];

      // Bán 1 gói x999 (999 viên) giá 40,000 VND
      final sales = [
        CskbSale(
          id: 'sale1',
          packCount: 1,
          looseCount: 0,
          unitPricePerPack: 40000.0,
          totalRevenue: 40000.0,
          currency: AppConstants.currencyVnd,
          createdAt: now,
        ),
      ];

      // Tự lấy ra dùng cá nhân: 1 gói x999 + 500 viên lẻ = 1,499 viên
      final usages = [
        CskbUsage(
          id: 'u1',
          packCount: 1,
          looseCount: 500,
          purpose: 'Mở Cải trang Dracula',
          createdAt: now,
        ),
      ];

      final summary = CalculationService.calculateSummary(
        purchases: purchases,
        sessions: sessions,
        sales: sales,
        usages: usages,
        expenses: [],
      );

      // Tồn kho: 3,000 (thu) - 999 (bán) - 1,499 (tự dùng) = 502 viên (0 gói + 502 lẻ)
      expect(summary.totalCskbCollected, 3000);
      expect(summary.totalCskbSold, 999);
      expect(summary.totalCskbUsed, 1499);
      expect(summary.usedPacks, 1);
      expect(summary.usedLoose, 500);
      expect(summary.currentCskbStock, 502);
      expect(summary.stockPacks, 0);
      expect(summary.stockLoose, 502);

      // Giá vốn 1 viên = 33.333 đ -> Giá vốn tự dùng: 1,499 * 33.333 = 49,966.67 đ
      expect(summary.personalConsumptionCostVnd, closeTo(1499 * (100000 / 3000), 0.1));
    });
  });
}
