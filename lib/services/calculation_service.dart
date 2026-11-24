import '../core/constants/app_constants.dart';
import '../models/detector_purchase.dart';
import '../models/farming_session.dart';
import '../models/cskb_sale.dart';
import '../models/cskb_usage.dart';
import '../models/other_expense.dart';
import '../models/profit_loss_summary.dart';

class CalculationService {
  /// Quy đổi tổng số CSKB thành số gói x999
  static int cskbToPacks(int totalCskb) {
    if (totalCskb <= 0) return 0;
    return totalCskb ~/ AppConstants.packSize;
  }

  /// Tính số lượng viên CSKB lẻ còn dư sau khi đóng gói x999
  static int cskbToLoose(int totalCskb) {
    if (totalCskb <= 0) return 0;
    return totalCskb % AppConstants.packSize;
  }

  /// Tính tổng số viên CSKB từ số gói x999 và số viên lẻ
  static int packsAndLooseToCskb(int packs, int loose) {
    return (packs * AppConstants.packSize) + loose;
  }

  /// Tính toán tổng hợp Lời / Lỗ và Tồn kho (bao gồm cả CSKB bán ra và tự dùng)
  static ProfitLossSummary calculateSummary({
    required List<DetectorPurchase> purchases,
    required List<FarmingSession> sessions,
    required List<CskbSale> sales,
    List<CskbUsage> usages = const [],
    required List<OtherExpense> expenses,
    double exchangeRateTvToVnd = AppConstants.defaultTvToVndRate,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // 1. Lọc theo khoảng thời gian nếu có
    final filteredPurchases = _filterByDate(purchases, startDate, endDate, (p) => p.createdAt);
    final filteredSessions = _filterByDate(sessions, startDate, endDate, (s) => s.createdAt);
    final filteredSales = _filterByDate(sales, startDate, endDate, (s) => s.createdAt);
    final filteredUsages = _filterByDate(usages, startDate, endDate, (u) => u.createdAt);
    final filteredExpenses = _filterByDate(expenses, startDate, endDate, (e) => e.createdAt);

    // 2. Thống kê Máy Dò
    int totalDetectorsPurchased = 0;
    double totalDetectorExpenseVnd = 0.0;
    double totalDetectorExpenseTv = 0.0;

    for (final p in filteredPurchases) {
      totalDetectorsPurchased += p.quantity;
      if (p.currency == AppConstants.currencyVnd) {
        totalDetectorExpenseVnd += p.totalPrice;
        totalDetectorExpenseTv += p.totalPrice / (exchangeRateTvToVnd > 0 ? exchangeRateTvToVnd : 1);
      } else {
        totalDetectorExpenseTv += p.totalPrice;
        totalDetectorExpenseVnd += p.totalPrice * exchangeRateTvToVnd;
      }
    }

    int totalDetectorsUsed = 0;
    int totalCskbCollected = 0;
    for (final s in filteredSessions) {
      totalDetectorsUsed += s.detectorsUsed;
      totalCskbCollected += s.cskbCollected;
    }

    final currentDetectorStock = totalDetectorsPurchased - totalDetectorsUsed;

    // 3. Hiệu suất rơi (Drop Rate)
    final averageDropRate = totalDetectorsUsed > 0
        ? (totalCskbCollected / totalDetectorsUsed)
        : 0.0;

    // 4. Thống kê Bán Hàng & Doanh thu
    int totalCskbSold = 0;
    double totalRevenueVnd = 0.0;
    double totalRevenueTv = 0.0;
    double latestPackPriceVnd = 0.0;

    for (final s in filteredSales) {
      totalCskbSold += s.totalCskb;
      if (s.currency == AppConstants.currencyVnd) {
        totalRevenueVnd += s.totalRevenue;
        totalRevenueTv += s.totalRevenue / (exchangeRateTvToVnd > 0 ? exchangeRateTvToVnd : 1);
        if (s.packCount > 0) {
          latestPackPriceVnd = s.unitPricePerPack;
        }
      } else {
        totalRevenueTv += s.totalRevenue;
        totalRevenueVnd += s.totalRevenue * exchangeRateTvToVnd;
        if (s.packCount > 0) {
          latestPackPriceVnd = s.unitPricePerPack * exchangeRateTvToVnd;
        }
      }
    }

    // 5. Thống kê CSKB Lấy Ra Sử Dụng Cá Nhân
    int totalCskbUsed = 0;
    for (final u in filteredUsages) {
      totalCskbUsed += u.totalCskb;
    }

    // Tồn kho CSKB thực tế = Tổng thu hoạch - Tổng đã bán - Tổng đã tự dùng
    final currentCskbStock = totalCskbCollected - totalCskbSold - totalCskbUsed;

    // 6. Giá vốn hàng bán (COGS - Cost of Goods Sold)
    // Giá vốn trung bình 1 máy dò (VND & TV):
    final avgCostPerDetectorVnd = totalDetectorsPurchased > 0
        ? (totalDetectorExpenseVnd / totalDetectorsPurchased)
        : 0.0;
    final avgCostPerDetectorTv = totalDetectorsPurchased > 0
        ? (totalDetectorExpenseTv / totalDetectorsPurchased)
        : 0.0;

    // Giá vốn của 1 viên CSKB:
    final avgCostPerCskbVnd = totalCskbCollected > 0
        ? ((totalDetectorsUsed * avgCostPerDetectorVnd) / totalCskbCollected)
        : 0.0;
    final avgCostPerCskbTv = totalCskbCollected > 0
        ? ((totalDetectorsUsed * avgCostPerDetectorTv) / totalCskbCollected)
        : 0.0;

    // Tổng giá vốn tương ứng với số lượng CSKB đã bán cho khách:
    final cogsVnd = totalCskbSold * avgCostPerCskbVnd;
    final cogsTv = totalCskbSold * avgCostPerCskbTv;

    // Giá trị tiêu dùng cá nhân (Chi phí giá vốn số CSKB đã tự mở/dùng)
    final personalConsumptionCostVnd = totalCskbUsed * avgCostPerCskbVnd;
    final personalConsumptionCostTv = totalCskbUsed * avgCostPerCskbTv;

    // Giá trị tương đương nếu phải bỏ tiền mua ngoài thị trường
    final personalConsumptionMarketValueVnd = latestPackPriceVnd > 0
        ? (totalCskbUsed / AppConstants.packSize) * latestPackPriceVnd
        : personalConsumptionCostVnd;

    // 7. Chi phí phụ khác (Bùa, VPS, ...)
    double otherExpensesVnd = 0.0;
    double otherExpensesTv = 0.0;
    for (final e in filteredExpenses) {
      if (e.currency == AppConstants.currencyVnd) {
        otherExpensesVnd += e.amount;
        otherExpensesTv += e.amount / (exchangeRateTvToVnd > 0 ? exchangeRateTvToVnd : 1);
      } else {
        otherExpensesTv += e.amount;
        otherExpensesVnd += e.amount * exchangeRateTvToVnd;
      }
    }

    // 8. Lợi nhuận ròng
    final netProfitVnd = totalRevenueVnd - cogsVnd - otherExpensesVnd;
    final netProfitTv = totalRevenueTv - cogsTv - otherExpensesTv;

    // 9. Định giá tồn kho ước tính
    final detectorStockValueVnd = currentDetectorStock > 0 ? currentDetectorStock * avgCostPerDetectorVnd : 0.0;
    final cskbStockValueVnd = currentCskbStock > 0
        ? (latestPackPriceVnd > 0
            ? (currentCskbStock / AppConstants.packSize) * latestPackPriceVnd
            : currentCskbStock * avgCostPerCskbVnd)
        : 0.0;
    final estimatedInventoryValueVnd = detectorStockValueVnd + cskbStockValueVnd;

    return ProfitLossSummary(
      totalRevenueVnd: totalRevenueVnd,
      totalRevenueTv: totalRevenueTv,
      totalDetectorExpenseVnd: totalDetectorExpenseVnd,
      totalDetectorExpenseTv: totalDetectorExpenseTv,
      cogsVnd: cogsVnd,
      cogsTv: cogsTv,
      otherExpensesVnd: otherExpensesVnd,
      otherExpensesTv: otherExpensesTv,
      netProfitVnd: netProfitVnd,
      netProfitTv: netProfitTv,
      totalDetectorsPurchased: totalDetectorsPurchased,
      totalDetectorsUsed: totalDetectorsUsed,
      currentDetectorStock: currentDetectorStock,
      totalCskbCollected: totalCskbCollected,
      totalCskbSold: totalCskbSold,
      totalCskbUsed: totalCskbUsed,
      currentCskbStock: currentCskbStock,
      personalConsumptionCostVnd: personalConsumptionCostVnd,
      personalConsumptionCostTv: personalConsumptionCostTv,
      personalConsumptionMarketValueVnd: personalConsumptionMarketValueVnd,
      averageDropRate: averageDropRate,
      estimatedInventoryValueVnd: estimatedInventoryValueVnd,
    );
  }

  static List<T> _filterByDate<T>(
    List<T> list,
    DateTime? start,
    DateTime? end,
    DateTime Function(T) getDate,
  ) {
    if (start == null && end == null) return list;
    return list.where((item) {
      final date = getDate(item);
      if (start != null && date.isBefore(start)) return false;
      if (end != null && date.isAfter(end)) return false;
      return true;
    }).toList();
  }
}
