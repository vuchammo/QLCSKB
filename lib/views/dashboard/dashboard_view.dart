import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/date_filter_bar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final summary = provider.summary;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bảng Điều Khiển Tổng Quan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hệ thống theo dõi & tối ưu hóa lợi nhuận Up Capsule Kì Bí (CSKB)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: AppTheme.successGreen, size: 10),
                      const SizedBox(width: 8),
                      Text(
                        '1 Thỏi Vàng = ${CurrencyFormatter.formatNumber(provider.exchangeRateTvToVnd)} đ',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bộ lọc thời gian
            const DateFilterBar(),
            const SizedBox(height: 20),

            // Lưới Thẻ Thống Kê (KPI Cards)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 750 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.8,
                  children: [
                    // Tồn kho CSKB
                    StatCard(
                      title: 'CSKB TỒN KHO',
                      value: '${CurrencyFormatter.formatNumber(summary.currentCskbStock)} viên',
                      subtitle: '= ${summary.stockPacks} gói x999 + ${summary.stockLoose} viên lẻ',
                      icon: Icons.inventory_2_outlined,
                      accentColor: AppTheme.primaryOrange,
                    ),

                    // Tồn kho Máy Dò
                    StatCard(
                      title: 'MÁY DÒ CÒN LẠI',
                      value: '${summary.currentDetectorStock} cái',
                      subtitle: 'Đã dùng: ${summary.totalDetectorsUsed} / Đã mua: ${summary.totalDetectorsPurchased}',
                      icon: Icons.radar,
                      accentColor: AppTheme.kiCyan,
                    ),

                    // Lợi Nhuận Ròng (Net Profit)
                    StatCard(
                      title: 'LỢI NHUẬN RÒNG (P&L)',
                      value: CurrencyFormatter.format(summary.netProfitVnd),
                      subtitle: summary.netProfitVnd >= 0
                          ? '+${summary.roiVnd.toStringAsFixed(1)}% ROI | ${CurrencyFormatter.format(summary.netProfitTv, currency: AppConstants.currencyThoiVang)}'
                          : '${summary.roiVnd.toStringAsFixed(1)}% ROI | Lỗ',
                      icon: Icons.trending_up,
                      accentColor: summary.netProfitVnd >= 0 ? AppTheme.successGreen : AppTheme.dangerRed,
                    ),

                    // Hiệu Suất Rơi (Drop Rate)
                    StatCard(
                      title: 'TỶ LỆ RƠI TRUNG BÌNH',
                      value: '${summary.averageDropRate.toStringAsFixed(1)} viên/máy',
                      subtitle: 'Thu hoạch: ${CurrencyFormatter.formatNumber(summary.totalCskbCollected)} CSKB',
                      icon: Icons.auto_awesome,
                      accentColor: AppTheme.primaryGold,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Dòng thứ hai của KPI (Tài chính mở rộng)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100 ? 3 : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    StatCard(
                      title: 'TỔNG DOANH THU BÁN CSKB',
                      value: CurrencyFormatter.format(summary.totalRevenueVnd),
                      subtitle: 'Bán: ${summary.totalCskbSold ~/ AppConstants.packSize} gói x999 (${CurrencyFormatter.format(summary.totalRevenueTv, currency: AppConstants.currencyThoiVang)})',
                      icon: Icons.payments_outlined,
                      accentColor: AppTheme.successGreen,
                    ),
                    StatCard(
                      title: 'GIÁ VỐN HÀNG BÁN (COGS)',
                      value: CurrencyFormatter.format(summary.cogsVnd),
                      subtitle: 'Chi phí máy dò cho số CSKB đã bán',
                      icon: Icons.receipt_long_outlined,
                      accentColor: AppTheme.dangerRed,
                    ),
                    StatCard(
                      title: 'ĐỊNH GIÁ TỔN KHO ƯỚC TÍNH',
                      value: CurrencyFormatter.format(summary.estimatedInventoryValueVnd),
                      subtitle: 'Giá trị quy đổi máy dò + CSKB tồn',
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppTheme.kiCyan,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Hai cột: Ca Up Gần Đây & Đơn Bán Gần Đây
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ca up gần đây
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.history, color: AppTheme.kiCyan, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ca Up Gần Đây',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                '${provider.farmingSessions.length} ca',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppTheme.borderDark),
                          if (provider.farmingSessions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Chưa có ca up nào được ghi nhận.', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.farmingSessions.take(5).length,
                              separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.borderDark),
                              itemBuilder: (context, index) {
                                final s = provider.farmingSessions[index];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '+${CurrencyFormatter.formatNumber(s.cskbCollected)} CSKB',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormatter.formatFull(s.createdAt),
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Dùng ${s.detectorsUsed} máy dò',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.kiCyan.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${s.dropRate.toStringAsFixed(1)} viên/máy',
                                            style: const TextStyle(fontSize: 10, color: AppTheme.kiCyan, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Đơn bán gần đây
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.sell_outlined, color: AppTheme.successGreen, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đơn Bán Gần Đây',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                '${provider.cskbSales.length} đơn',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppTheme.borderDark),
                          if (provider.cskbSales.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Chưa có đơn bán nào.', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.cskbSales.take(5).length,
                              separatorBuilder: (_, __) => const Divider(height: 16, color: AppTheme.borderDark),
                              itemBuilder: (context, index) {
                                final sale = provider.cskbSales[index];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bán ${sale.packCount} gói x999${sale.looseCount > 0 ? " + ${sale.looseCount} lẻ" : ""}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${sale.customerName.isNotEmpty ? "${sale.customerName} • " : ""}${DateFormatter.formatFull(sale.createdAt)}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(sale.totalRevenue, currency: sale.currency),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.successGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: sale.isPaid
                                                ? AppTheme.successGreen.withOpacity(0.15)
                                                : AppTheme.dangerRed.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            sale.isPaid ? 'ĐÃ THU' : 'GHI NỢ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: sale.isPaid ? AppTheme.successGreen : AppTheme.dangerRed,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
