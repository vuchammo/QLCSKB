import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/farming_session.dart';

class FarmingView extends StatelessWidget {
  const FarmingView({super.key});

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
                      'Kho CSKB & Ca Treo Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Theo dõi tổng lượng Capsule Kì Bí hiện có, quy đổi gói x999 và hiệu suất ca up',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddSessionDialog(context),
                  icon: const Icon(Icons.add_task, size: 18),
                  label: const Text('Ghi Ca Up Mới'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Banner Tổng Kho CSKB (Quy chuẩn x999)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryOrange.withOpacity(0.15),
                      AppTheme.cardDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryOrange, width: 2),
                      ),
                      child: const Icon(Icons.inventory_2, color: AppTheme.primaryOrange, size: 40),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TỔNG CAPSULE KÌ BÍ (CSKB) HIỆN CÓ TRONG KHO',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                CurrencyFormatter.formatNumber(summary.currentCskbStock),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'viên',
                                style: TextStyle(fontSize: 18, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Quy đổi gói x999
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
                                ),
                                child: Text(
                                  '📦 ${summary.stockPacks} Gói tiêu chuẩn (x999 CSKB)',
                                  style: const TextStyle(
                                    color: AppTheme.primaryGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  '🔹 ${summary.stockLoose} Viên lẻ dư',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.kiCyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.kiCyan.withOpacity(0.5)),
                                ),
                                child: Text(
                                  '📡 Máy dò còn: ${summary.currentDetectorStock} cái',
                                  style: const TextStyle(
                                    color: AppTheme.kiCyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bảng lịch sử các ca up
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
                            Icon(Icons.history_toggle_off, color: AppTheme.kiCyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Nhật Ký Các Ca Treo Up CSKB',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '${provider.farmingSessions.length} ca up',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    if (provider.farmingSessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Chưa có ca up nào được ghi nhận.\nBấm "Ghi Ca Up Mới" sau mỗi lần treo máy để tích lũy dữ liệu!',
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
                            DataColumn(label: Text('Máy Dò Đã Dùng', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('CSKB Thu Được', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tỷ Lệ Rơi (Drop Rate)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Server / Vũ Trụ', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tài Khoản / Ghi Chú', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.farmingSessions.map((session) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormatter.formatFull(session.createdAt),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${session.detectorsUsed} cái',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.kiCyan),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '+${CurrencyFormatter.formatNumber(session.cskbCollected)} viên',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: session.dropRate >= 20
                                          ? AppTheme.successGreen.withOpacity(0.15)
                                          : Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${session.dropRate.toStringAsFixed(1)} viên/máy',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: session.dropRate >= 20 ? AppTheme.successGreen : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(session.server),
                                ),
                                DataCell(
                                  Text(
                                    session.note?.isNotEmpty == true
                                        ? '${session.accountName.isNotEmpty ? "${session.accountName} - " : ""}${session.note}'
                                        : (session.accountName.isNotEmpty ? session.accountName : '---'),
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerRed),
                                    tooltip: 'Xóa ca up này',
                                    onPressed: () => _confirmDelete(context, session.id),
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

  void _showAddSessionDialog(BuildContext context) {
    final detectorsController = TextEditingController();
    final cskbController = TextEditingController();
    final serverController = TextEditingController(text: 'Vũ trụ 1');
    final accountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final detectors = int.tryParse(detectorsController.text.trim()) ?? 0;
            final cskb = int.tryParse(cskbController.text.trim()) ?? 0;
            final previewDropRate = detectors > 0 ? (cskb / detectors) : 0.0;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_task, color: AppTheme.primaryOrange),
                  SizedBox(width: 8),
                  Text('Ghi Nhận Ca Treo Up CSKB'),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số máy dò đã dùng trong ca:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: detectorsController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: 10',
                          suffixText: 'máy dò',
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Số viên CSKB thu hoạch được:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: cskbController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: 250',
                          suffixText: 'viên CSKB',
                        ),
                      ),

                      if (detectors > 0 && cskb > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.bgDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.kiCyan.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.speed, color: AppTheme.kiCyan, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Hiệu suất rơi: ${previewDropRate.toStringAsFixed(1)} viên/máy dò',
                                style: const TextStyle(color: AppTheme.kiCyan, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Server / Vũ Trụ:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: serverController,
                                  decoration: const InputDecoration(
                                    hintText: 'Vũ trụ 1',
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
                                const Text('Nick / Tài khoản up:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: accountController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tùy chọn',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text('Thời gian ca up:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryOrange),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Ghi chú ca up:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Map Đông Karin, đệ tử up, bùa thu hút...',
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
                    final detectorsCount = int.tryParse(detectorsController.text.trim()) ?? 0;
                    final cskbCount = int.tryParse(cskbController.text.trim()) ?? 0;

                    if (detectorsCount <= 0 || cskbCount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập số máy dò và số CSKB lớn hơn 0!')),
                      );
                      return;
                    }

                    final session = FarmingSession(
                      id: const Uuid().v4(),
                      detectorsUsed: detectorsCount,
                      cskbCollected: cskbCount,
                      server: serverController.text.trim().isNotEmpty ? serverController.text.trim() : 'Vũ trụ 1',
                      accountName: accountController.text.trim(),
                      createdAt: selectedDateTime,
                      note: noteController.text.trim(),
                    );

                    context.read<AppProvider>().addFarmingSession(session);
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Lưu Ca Up'),
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
        content: const Text('Bạn có chắc chắn muốn xóa ca up này? Số lượng tồn kho CSKB và hiệu suất sẽ được tính toán lại.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AppProvider>().deleteFarmingSession(id);
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
