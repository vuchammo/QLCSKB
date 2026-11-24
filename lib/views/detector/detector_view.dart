import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/detector_purchase.dart';
import '../../core/widgets/stat_card.dart';

class DetectorView extends StatelessWidget {
  const DetectorView({super.key});

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
                        'Quản Lý Máy Dò Capsule Kì Bí',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ghi nhận chi phí mua máy dò, theo dõi số lượng tồn và giá vốn',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddPurchaseDialog(context),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Nhập Máy Dò Mới'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Thống kê nhanh
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
                      title: 'MÁY DÒ CÒN TỒN',
                      value: '${summary.currentDetectorStock} cái',
                      subtitle: 'Sẵn sàng kích hoạt cho ca up',
                      icon: Icons.radar,
                      accentColor: AppTheme.kiCyan,
                    ),
                    StatCard(
                      title: 'TỔNG MÁY DÒ ĐÃ MUA',
                      value: '${summary.totalDetectorsPurchased} cái',
                      subtitle: 'Đã sử dụng: ${summary.totalDetectorsUsed} cái',
                      icon: Icons.inventory,
                      accentColor: AppTheme.primaryGold,
                    ),
                    StatCard(
                      title: 'TỔNG CHI PHÍ MUA MÁY DÒ',
                      value: CurrencyFormatter.format(summary.totalDetectorExpenseVnd),
                      subtitle: 'Tương đương: ${CurrencyFormatter.format(summary.totalDetectorExpenseTv, currency: AppConstants.currencyThoiVang)}',
                      icon: Icons.attach_money,
                      accentColor: AppTheme.dangerRed,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Bảng lịch sử mua máy dò
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
                            Icon(Icons.history, color: AppTheme.kiCyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Lịch Sử Nhập Máy Dò',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '${provider.detectorPurchases.length} lần nhập',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    if (provider.detectorPurchases.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Chưa có lần nhập máy dò nào.\nBấm "Nhập Máy Dò Mới" để bắt đầu theo dõi!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.5),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 28,
                          columns: const [
                            DataColumn(label: Text('Thời Gian Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Số Lượng', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Đơn Giá/Cái', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tổng Tiền', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tiền Tệ', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Ghi Chú', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.detectorPurchases.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormatter.formatFull(p.createdAt),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${CurrencyFormatter.formatNumber(p.quantity)} cái',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.kiCyan),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    CurrencyFormatter.format(p.unitPrice, currency: p.currency),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    CurrencyFormatter.format(p.totalPrice, currency: p.currency),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: p.currency == AppConstants.currencyVnd
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p.currency,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: p.currency == AppConstants.currencyVnd ? Colors.blue : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    p.note?.isNotEmpty == true ? p.note! : '---',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerRed),
                                    tooltip: 'Xóa giao dịch này',
                                    onPressed: () => _confirmDelete(context, p.id),
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

  void _showAddPurchaseDialog(BuildContext context) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCurrency = AppConstants.currencyVnd;
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: AppTheme.primaryGold),
                  SizedBox(width: 8),
                  Text('Nhập Máy Dò Capsule Kì Bí'),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số lượng máy dò mua:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: 100',
                          suffixText: 'cái',
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Tiền tệ thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('VND (Tiền mặt)'),
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

                      const Text('Tổng số tiền đã trả:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: selectedCurrency == AppConstants.currencyVnd ? 'Ví dụ: 100000' : 'Ví dụ: 50',
                          suffixText: selectedCurrency,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Thời gian mua:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryGold),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Ghi chú (Tùy chọn):', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Mua của NPC Bunma, shop Game, v.v.',
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
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                    final price = double.tryParse(priceController.text.trim().replaceAll(',', '')) ?? 0.0;

                    if (qty <= 0 || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập số lượng và tổng tiền hợp lệ!')),
                      );
                      return;
                    }

                    final purchase = DetectorPurchase(
                      id: const Uuid().v4(),
                      quantity: qty,
                      totalPrice: price,
                      currency: selectedCurrency,
                      createdAt: selectedDateTime,
                      note: noteController.text.trim(),
                    );

                    context.read<AppProvider>().addDetectorPurchase(purchase);
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Lưu Giao Dịch'),
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
        content: const Text('Bạn có chắc chắn muốn xóa lần nhập máy dò này? Dữ liệu tồn kho và lời lỗ sẽ được cập nhật lại.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AppProvider>().deleteDetectorPurchase(id);
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
