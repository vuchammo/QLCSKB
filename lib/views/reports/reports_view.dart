import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/date_filter_bar.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final summary = provider.summary;

    final grossProfitVnd = summary.totalRevenueVnd - summary.cogsVnd;
    final grossProfitTv = summary.totalRevenueTv - summary.cogsTv;

    // Dòng tiền thực tế
    final cashflowVnd = summary.totalRevenueVnd - summary.totalDetectorExpenseVnd - summary.otherExpensesVnd;
    final cashflowTv = summary.totalRevenueTv - summary.totalDetectorExpenseTv - summary.otherExpensesTv;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Báo Cáo Tài Chính & Lời Lỗ (P&L)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Phân tích doanh thu, giá vốn máy dò tiêu hao, chi phí phụ và lợi nhuận ròng thực tế',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),

            // Bộ lọc thời gian
            const DateFilterBar(),
            const SizedBox(height: 20),

            // Card Tóm tắt Lợi Nhuận Lớn
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      (summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed).withOpacity(0.12),
                      AppTheme.cardDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LỢI NHUẬN RÒNG (NET PROFIT)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(summary.netProfitVnd),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Quy đổi: ${CurrencyFormatter.format(summary.netProfitTv, currency: AppConstants.currencyThoiVang)} (Tỷ giá: 1 TV = ${CurrencyFormatter.formatNumber(provider.exchangeRateTvToVnd)} đ)',
                              style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: (summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            summary.netProfitVnd >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppTheme.borderDark),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 650;
                        final item1 = _buildSummaryItem(
                          'Tỷ Suất ROI',
                          '${summary.roiVnd.toStringAsFixed(1)}%',
                          summary.roiVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                        );
                        final item2 = _buildSummaryItem(
                          'CSKB Đã Bán',
                          '${summary.totalCskbSold ~/ AppConstants.packSize} gói x999',
                          AppTheme.primaryGold,
                        );
                        final item3 = _buildSummaryItem(
                          'Dòng Tiền Thực',
                          CurrencyFormatter.format(cashflowVnd),
                          cashflowVnd >= 0 ? AppTheme.kiCyan : AppTheme.dangerRed,
                          subtitle: CurrencyFormatter.format(cashflowTv, currency: AppConstants.currencyThoiVang),
                        );
                        final item4 = _buildSummaryItem(
                          'Tồn Kho Ước Tính',
                          CurrencyFormatter.format(summary.estimatedInventoryValueVnd),
                          Colors.purpleAccent,
                        );

                        if (isWide) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(child: item1),
                              Expanded(child: item2),
                              Expanded(child: item3),
                              Expanded(child: item4),
                            ],
                          );
                        } else {
                          final halfWidth = (constraints.maxWidth - 24) / 2;
                          return Wrap(
                            alignment: WrapAlignment.spaceAround,
                            runSpacing: 16,
                            spacing: 16,
                            children: [
                              SizedBox(width: halfWidth, child: item1),
                              SizedBox(width: halfWidth, child: item2),
                              SizedBox(width: halfWidth, child: item3),
                              SizedBox(width: halfWidth, child: item4),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bảng Chi Tiết Báo Cáo Tài Chính (Detailed P&L Table)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.table_chart, color: AppTheme.kiCyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Bảng Kê Chi Tiết Doanh Thu & Chi Phí',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),

                    // 1. DOANH THU
                    _buildPlRow(
                      title: '1. Doanh thu bán Capsule Kì Bí (CSKB)',
                      description: 'Thu từ việc bán các gói x999 CSKB và viên lẻ',
                      amountVnd: summary.totalRevenueVnd,
                      amountTv: summary.totalRevenueTv,
                      color: AppTheme.successGreen,
                      isBold: true,
                    ),
                    const Divider(height: 16, color: AppTheme.borderDark),

                    // 2. GIÁ VỐN HÀNG BÁN
                    _buildPlRow(
                      title: '2. Giá vốn máy dò (COGS - Cost of Goods Sold)',
                      description: 'Chi phí mua máy dò phân bổ cho số lượng CSKB đã bán',
                      amountVnd: -summary.cogsVnd,
                      amountTv: -summary.cogsTv,
                      color: AppTheme.dangerRed,
                    ),
                    const Divider(height: 16, color: AppTheme.borderDark),

                    // 3. LỢI NHUẬN GỘP
                    _buildPlRow(
                      title: '3. Lợi nhuận gộp (Gross Profit)',
                      description: 'Doanh thu thuần trừ đi giá vốn máy dò',
                      amountVnd: grossProfitVnd,
                      amountTv: grossProfitTv,
                      color: grossProfitVnd >= 0 ? AppTheme.primaryGold : AppTheme.dangerRed,
                      isBold: true,
                      backgroundColor: AppTheme.primaryGold.withOpacity(0.05),
                    ),
                    const Divider(height: 16, color: AppTheme.borderDark),

                    // 4. CHI PHÍ VẬN HÀNH PHỤ
                    _buildPlRow(
                      title: '4. Chi phí phụ trợ khác',
                      description: 'Tiền bùa dẻo dai/thu hút, đậu thần, tiền điện, VPS treo nick',
                      amountVnd: -summary.otherExpensesVnd,
                      amountTv: -summary.otherExpensesTv,
                      color: AppTheme.dangerRed,
                    ),
                    const Divider(height: 16, color: AppTheme.borderDark),

                    // 5. LỢI NHUẬN RÒNG BÁN HÀNG
                    _buildPlRow(
                      title: '5. LỢI NHUẬN RÒNG BÁN HÀNG (NET PROFIT)',
                      description: 'Lợi nhuận ròng thu về từ hoạt động bán hàng',
                      amountVnd: summary.netProfitVnd,
                      amountTv: summary.netProfitTv,
                      color: summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                      isBold: true,
                      backgroundColor: (summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed).withOpacity(0.1),
                    ),
                    const Divider(height: 16, color: AppTheme.borderDark),

                    // 6. GIÁ TRỊ CSKB TỰ SỬ DỤNG CHO CÁ NHÂN
                    _buildPlRow(
                      title: '6. Giá trị CSKB đã xuất tự dùng (Cá nhân)',
                      description: 'Tự dùng ${summary.usedPacks} gói${summary.usedLoose > 0 ? " + ${summary.usedLoose} lẻ" : ""} (${CurrencyFormatter.formatNumber(summary.totalCskbUsed)} viên) • Giá vốn tiêu thụ',
                      amountVnd: summary.personalConsumptionCostVnd,
                      amountTv: summary.personalConsumptionCostTv,
                      color: Colors.purpleAccent,
                      isBold: true,
                      backgroundColor: Colors.purpleAccent.withOpacity(0.08),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card Thống Kê Hiệu Suất Cày (Efficiency Breakdown)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.insights, color: AppTheme.primaryOrange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Chỉ Số Hiệu Suất & Tiêu Thụ CSKB',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        final tile1 = _buildMetricTile(
                          'Tỉ lệ rơi trung bình',
                          '${summary.averageDropRate.toStringAsFixed(1)} CSKB / máy',
                          'Dùng ${summary.totalDetectorsUsed} máy dò -> nhặt ${CurrencyFormatter.formatNumber(summary.totalCskbCollected)} CSKB',
                        );
                        final tile2 = _buildMetricTile(
                          'Máy dò cần để đóng 1 gói x999',
                          summary.averageDropRate > 0
                              ? '${(AppConstants.packSize / summary.averageDropRate).toStringAsFixed(1)} cái'
                              : '0 cái',
                          'Cần ~${summary.averageDropRate > 0 ? (AppConstants.packSize / summary.averageDropRate * 30 / 60).toStringAsFixed(1) : 0} giờ treo máy / gói',
                        );
                        final tile3 = _buildMetricTile(
                          'CSKB Tự Dùng Cá Nhân',
                          '${CurrencyFormatter.formatNumber(summary.totalCskbUsed)} viên',
                          'Đã mở ${summary.usedPacks} gói${summary.usedLoose > 0 ? " + ${summary.usedLoose} lẻ" : ""} (Vốn: ${CurrencyFormatter.format(summary.personalConsumptionCostVnd)})',
                          accentColor: Colors.purpleAccent,
                        );
                        final tile4 = _buildMetricTile(
                          'CSKB còn tồn kho',
                          '${CurrencyFormatter.formatNumber(summary.currentCskbStock)} viên',
                          'Tương đương ${summary.stockPacks} gói x999 + ${summary.stockLoose} lẻ',
                        );

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: tile1),
                              const SizedBox(width: 12),
                              Expanded(child: tile2),
                              const SizedBox(width: 12),
                              Expanded(child: tile3),
                              const SizedBox(width: 12),
                              Expanded(child: tile4),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              tile1,
                              const SizedBox(height: 10),
                              tile2,
                              const SizedBox(height: 10),
                              tile3,
                              const SizedBox(height: 10),
                              tile4,
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, {String? subtitle}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ],
    );
  }

  Widget _buildPlRow({
    required String title,
    required String description,
    required double amountVnd,
    required double amountTv,
    required Color color,
    bool isBold = false,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isBold ? 15 : 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (amountVnd > 0 && isBold ? '+' : '') + CurrencyFormatter.format(amountVnd),
                style: TextStyle(
                  fontSize: isBold ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.format(amountTv, currency: AppConstants.currencyThoiVang),
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, {Color accentColor = AppTheme.primaryGold}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
