import '../core/constants/app_constants.dart';

class ProfitLossSummary {
  // Doanh thu
  final double totalRevenueVnd;
  final double totalRevenueTv;

  // Chi phí máy dò đã mua
  final double totalDetectorExpenseVnd;
  final double totalDetectorExpenseTv;

  // Giá vốn hàng bán (COGS - chi phí máy dò tương ứng với lượng CSKB đã bán)
  final double cogsVnd;
  final double cogsTv;

  // Chi phí phụ (Bùa, VPS, đậu...)
  final double otherExpensesVnd;
  final double otherExpensesTv;

  // Lợi nhuận ròng (Net Profit) = Doanh thu - COGS - Chi phí phụ
  final double netProfitVnd;
  final double netProfitTv;

  // Tồn kho hiện tại
  final int totalDetectorsPurchased;
  final int totalDetectorsUsed;
  final int currentDetectorStock; // Số máy dò còn lại

  final int totalCskbCollected;
  final int totalCskbSold;
  final int currentCskbStock; // Tổng số viên CSKB còn tồn

  // Hiệu suất
  final double averageDropRate; // Trung bình số CSKB nhặt được trên 1 máy dò

  // Định giá tồn kho ước tính (dựa trên giá vốn bình quân hoặc giá bán gần nhất)
  final double estimatedInventoryValueVnd;

  ProfitLossSummary({
    required this.totalRevenueVnd,
    required this.totalRevenueTv,
    required this.totalDetectorExpenseVnd,
    required this.totalDetectorExpenseTv,
    required this.cogsVnd,
    required this.cogsTv,
    required this.otherExpensesVnd,
    required this.otherExpensesTv,
    required this.netProfitVnd,
    required this.netProfitTv,
    required this.totalDetectorsPurchased,
    required this.totalDetectorsUsed,
    required this.currentDetectorStock,
    required this.totalCskbCollected,
    required this.totalCskbSold,
    required this.currentCskbStock,
    required this.averageDropRate,
    required this.estimatedInventoryValueVnd,
  });

  // Tự động quy đổi số gói x999 và số viên lẻ
  int get stockPacks => currentCskbStock ~/ AppConstants.packSize;
  int get stockLoose => currentCskbStock % AppConstants.packSize;

  // Tỷ suất sinh lời ROI (%)
  double get roiVnd {
    final totalCost = cogsVnd + otherExpensesVnd;
    if (totalCost <= 0) return 0.0;
    return (netProfitVnd / totalCost) * 100;
  }
}
