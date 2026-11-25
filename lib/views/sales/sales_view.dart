import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/cskb_sale.dart';
import '../../core/widgets/stat_card.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quản Lý Bán Capsule Kì Bí (CSKB)',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ghi nhận đơn xuất bán theo gói tiêu chuẩn x999 CSKB, theo dõi giá và công nợ',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddSaleDialog(context),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Tạo Đơn Bán Mới'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Thẻ thống kê bán hàng
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 3
                    : (constraints.maxWidth > 550 ? 2 : 1);
                return GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 125,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      title: 'TỔNG CSKB ĐÃ XUẤT BÁN',
                      value: '${summary.totalCskbSold ~/ AppConstants.packSize} gói x999',
                      subtitle: 'Tổng cộng: ${CurrencyFormatter.formatNumber(summary.totalCskbSold)} viên',
                      icon: Icons.sell,
                      accentColor: AppTheme.primaryOrange,
                    ),
                    StatCard(
                      title: 'TỔNG DOANH THU (VND)',
                      value: CurrencyFormatter.format(summary.totalRevenueVnd),
                      subtitle: 'Đã quy đổi theo tỷ giá',
                      icon: Icons.payments,
                      accentColor: AppTheme.successGreen,
                    ),
                    StatCard(
                      title: 'TỔNG DOANH THU (THỎI VÀNG)',
                      value: CurrencyFormatter.format(summary.totalRevenueTv, currency: AppConstants.currencyThoiVang),
                      subtitle: 'Đơn vị tiền tệ chính trong NRO',
                      icon: Icons.monetization_on,
                      accentColor: AppTheme.primaryGold,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Bảng danh sách đơn bán
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, color: AppTheme.successGreen, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Danh Sách Đơn Xuất Bán CSKB',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '${provider.cskbSales.length} đơn hàng',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    if (provider.cskbSales.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Chưa có đơn bán nào.\nBấm "Tạo Đơn Bán Mới" để xuất bán các gói x999 CSKB!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.5),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 26,
                          columns: const [
                            DataColumn(label: Text('Thời Gian Bán', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Số Lượng Bán', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Đơn Giá/Gói', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tổng Tiền', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Khách Hàng', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Server', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Thanh Toán', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Ghi Chú', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.cskbSales.map((sale) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormatter.formatFull(sale.createdAt),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '📦 ${sale.packCount} gói (x999)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                      ),
                                      if (sale.looseCount > 0)
                                        Text(
                                          '+ ${sale.looseCount} viên lẻ',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    CurrencyFormatter.format(sale.unitPricePerPack, currency: sale.currency),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    CurrencyFormatter.format(sale.totalRevenue, currency: sale.currency),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                                  ),
                                ),
                                DataCell(
                                  Text(sale.customerName.isNotEmpty ? sale.customerName : 'Khách vãng lai'),
                                ),
                                DataCell(
                                  Text(sale.server),
                                ),
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      context.read<AppProvider>().toggleSaleStatus(sale.id);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: sale.isPaid
                                            ? AppTheme.successGreen.withOpacity(0.15)
                                            : AppTheme.dangerRed.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: sale.isPaid ? AppTheme.successGreen : AppTheme.dangerRed,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            sale.isPaid ? Icons.check_circle : Icons.warning_amber,
                                            size: 14,
                                            color: sale.isPaid ? AppTheme.successGreen : AppTheme.dangerRed,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            sale.isPaid ? 'ĐÃ THU' : 'GHI NỢ',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: sale.isPaid ? AppTheme.successGreen : AppTheme.dangerRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(sale.note?.isNotEmpty == true ? sale.note! : '---', style: TextStyle(color: Colors.grey[400])),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerRed),
                                    tooltip: 'Xóa đơn bán này',
                                    onPressed: () => _confirmDelete(context, sale.id),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
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

  void _showAddSaleDialog(BuildContext context) {
    final defaultServer = context.read<AppProvider>().defaultServer;
    final packCountController = TextEditingController(text: '1');
    final looseCountController = TextEditingController(text: '0');
    final pricePerPackController = TextEditingController();
    final customerController = TextEditingController();
    final serverController = TextEditingController(text: defaultServer);
    final noteController = TextEditingController();
    String selectedCurrency = AppConstants.currencyVnd;
    String selectedStatus = 'PAID';
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final packs = int.tryParse(packCountController.text.trim()) ?? 0;
            final loose = int.tryParse(looseCountController.text.trim()) ?? 0;
            final unitPrice = double.tryParse(pricePerPackController.text.trim().replaceAll(',', '')) ?? 0.0;

            final totalCalculatedRevenue = (packs * unitPrice) + (loose > 0 ? (loose / AppConstants.packSize * unitPrice) : 0.0);
            final totalCskbToSell = (packs * AppConstants.packSize) + loose;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.sell, color: AppTheme.successGreen),
                  SizedBox(width: 8),
                  Text('Tạo Đơn Bán Capsule Kì Bí (CSKB)'),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Số gói x999 và viên lẻ
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Số gói bán (x999):', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: packCountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: 'Ví dụ: 1',
                                    suffixText: 'gói',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Viên lẻ kèm theo:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: looseCountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    suffixText: 'viên',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng số lượng CSKB xuất kho: ${CurrencyFormatter.formatNumber(totalCskbToSell)} viên',
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Tiền tệ
                      const Text('Đơn vị tiền tệ nhận:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('VND (Tiền mặt/MoMo)'),
                              value: AppConstants.currencyVnd,
                              groupValue: selectedCurrency,
                              onChanged: (val) => setState(() => selectedCurrency = val!),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Thỏi Vàng (TV)'),
                              value: AppConstants.currencyThoiVang,
                              groupValue: selectedCurrency,
                              onChanged: (val) => setState(() => selectedCurrency = val!),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Đơn giá trên mỗi gói x999
                      const Text('Giá tiền cho 1 gói (x999 CSKB):', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: pricePerPackController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: selectedCurrency == AppConstants.currencyVnd ? 'Ví dụ: 40000' : 'Ví dụ: 45',
                          suffixText: '$selectedCurrency / gói',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tổng tiền thành tiền
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.successGreen.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng tiền thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              CurrencyFormatter.format(totalCalculatedRevenue, currency: selectedCurrency),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Khách hàng & Server
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tên người mua / Nick:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: customerController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ví dụ: Anh Nam, Shop X...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Server / Vũ Trụ:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: serverController,
                                  decoration: InputDecoration(
                                    hintText: defaultServer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: AppConstants.serverList.take(4).map((s) {
                                    return InkWell(
                                      onTap: () => setState(() => serverController.text = s),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.white12),
                                        ),
                                        child: Text(s, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Trạng thái thanh toán
                      const Text('Trạng thái thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Đã nhận tiền'),
                            selected: selectedStatus == 'PAID',
                            selectedColor: AppTheme.successGreen,
                            labelStyle: TextStyle(
                              color: selectedStatus == 'PAID' ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) => setState(() => selectedStatus = 'PAID'),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text('Ghi nợ (chưa trả)'),
                            selected: selectedStatus == 'DEBT',
                            selectedColor: AppTheme.dangerRed,
                            labelStyle: TextStyle(
                              color: selectedStatus == 'DEBT' ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) => setState(() => selectedStatus = 'DEBT'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Thời gian bán
                      const Text('Thời gian bán chi tiết:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (date != null && dialogCtx.mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderDark),
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.bgDark,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormatter.formatFull(selectedDateTime)),
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.successGreen),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Ghi chú đơn hàng:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: GD tại đảo Kame, cọc trước 50%...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final packCount = int.tryParse(packCountController.text.trim()) ?? 0;
                    final looseCount = int.tryParse(looseCountController.text.trim()) ?? 0;
                    final unitPrice = double.tryParse(pricePerPackController.text.trim().replaceAll(',', '')) ?? 0.0;

                    if ((packCount <= 0 && looseCount <= 0) || unitPrice <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập số lượng và giá bán hợp lệ!')),
                      );
                      return;
                    }

                    final sale = CskbSale(
                      id: const Uuid().v4(),
                      packCount: packCount,
                      looseCount: looseCount,
                      unitPricePerPack: unitPrice,
                      totalRevenue: totalCalculatedRevenue,
                      currency: selectedCurrency,
                      customerName: customerController.text.trim(),
                      server: serverController.text.trim().isNotEmpty ? serverController.text.trim() : defaultServer,
                      createdAt: selectedDateTime,
                      status: selectedStatus,
                      note: noteController.text.trim(),
                    );

                    await context.read<AppProvider>().addCskbSale(sale);
                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                    }
                  },
                  child: const Text('Lưu Đơn Bán'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn bán này? Số lượng tồn kho và doanh thu sẽ được hoàn lại.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AppProvider>().deleteCskbSale(id);
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
