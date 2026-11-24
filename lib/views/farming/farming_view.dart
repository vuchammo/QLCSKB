import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/farming_session.dart';
import '../../models/cskb_usage.dart';

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
                Expanded(
                  child: Column(
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
                        'Theo dõi tổng lượng Capsule Kì Bí hiện có, xuất dùng cá nhân và hiệu suất ca up',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purpleAccent,
                        side: const BorderSide(color: Colors.purpleAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: () => _showAddUsageDialog(context, provider),
                      icon: const Icon(Icons.card_giftcard, size: 18),
                      label: const Text('Xuất Dùng Cá Nhân'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: () => _showAddSessionDialog(context),
                      icon: const Icon(Icons.add_task, size: 18),
                      label: const Text('Ghi Ca Up Mới'),
                    ),
                  ],
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
                          // Quy đổi gói x999 & Thống kê sử dụng
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
                              if (summary.totalCskbUsed > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    '🎁 Đã tự dùng: ${summary.usedPacks} gói${summary.usedLoose > 0 ? " + ${summary.usedLoose} lẻ" : ""} (${CurrencyFormatter.formatNumber(summary.totalCskbUsed)} viên)',
                                    style: const TextStyle(
                                      color: Colors.purpleAccent,
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

            // Tab Lịch Sử: Ca Up CSKB & Lịch Sử Xuất Dùng Cá Nhân
            DefaultTabController(
              length: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        indicatorColor: AppTheme.primaryGold,
                        labelColor: AppTheme.primaryGold,
                        unselectedLabelColor: Colors.grey,
                        isScrollable: true,
                        tabs: [
                          Tab(
                            icon: const Icon(Icons.history_toggle_off),
                            text: '1. Nhật Ký Ca Treo Up (${provider.farmingSessions.length} ca)',
                          ),
                          Tab(
                            icon: const Icon(Icons.card_giftcard),
                            text: '2. Lịch Sử Dùng Cá Nhân (${provider.cskbUsages.length} lần)',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 480,
                        child: TabBarView(
                          children: [
                            // TAB 1: CA TREO UP CSKB
                            _buildFarmingSessionsTab(context, provider),

                            // TAB 2: LỊCH SỬ XUẤT DÙNG CÁ NHÂN
                            _buildPersonalUsagesTab(context, provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmingSessionsTab(BuildContext context, AppProvider provider) {
    if (provider.farmingSessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Chưa có ca up nào được ghi nhận.\nBấm "Ghi Ca Up Mới" sau mỗi lần treo máy để tích lũy dữ liệu!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
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
                    '${session.detectorsUsed} máy dò',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                    onPressed: () => _confirmDeleteSession(context, session.id),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPersonalUsagesTab(BuildContext context, AppProvider provider) {
    if (provider.cskbUsages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 12),
              const Text(
                'Chưa có lần xuất dùng CSKB cá nhân nào.\nBấm "Xuất Dùng Cá Nhân" để ghi nhận khi mở Cải trang Dracula, đồ sao, vàng hoặc đậu thần!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                onPressed: () => _showAddUsageDialog(context, provider),
                icon: const Icon(Icons.card_giftcard, size: 16),
                label: const Text('Xuất Dùng Lần Đầu'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('Thời Gian Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Số Lượng Xuất Dùng', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mục Đích Sử Dụng', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Nhân Vật / Server', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ghi Chú / Kết Quả Mở', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: provider.cskbUsages.map((usage) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    DateFormatter.formatFull(usage.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          usage.packCount > 0
                              ? '${usage.packCount} gói x999${usage.looseCount > 0 ? " + ${usage.looseCount} lẻ" : ""}'
                              : '${usage.looseCount} viên lẻ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purpleAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${CurrencyFormatter.formatNumber(usage.totalCskb)} viên)',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                    ),
                    child: Text(
                      usage.purpose,
                      style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${usage.characterName?.isNotEmpty == true ? "${usage.characterName} • " : ""}${usage.server}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  Text(
                    usage.note?.isNotEmpty == true ? usage.note! : '---',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerRed),
                    tooltip: 'Xóa lượt dùng này (hoàn lại kho CSKB)',
                    onPressed: () => _confirmDeleteUsage(context, usage.id),
                  ),
                ),
              ],
            );
          }).toList(),
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

  void _showAddUsageDialog(BuildContext context, AppProvider provider) {
    final packController = TextEditingController(text: '0');
    final looseController = TextEditingController(text: '0');
    final purposeController = TextEditingController(text: 'Mở Cải trang Dracula');
    final characterController = TextEditingController(text: provider.memberName);
    final serverController = TextEditingController(text: 'Vũ trụ 1');
    final noteController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    final stock = provider.summary.currentCskbStock;
    final stockPacks = provider.summary.stockPacks;
    final stockLoose = provider.summary.stockLoose;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final packs = int.tryParse(packController.text.trim()) ?? 0;
            final loose = int.tryParse(looseController.text.trim()) ?? 0;
            final totalWanted = (packs * AppConstants.packSize) + loose;
            final remainingAfter = stock - totalWanted;
            final isOverStock = totalWanted > stock;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.purpleAccent),
                  SizedBox(width: 8),
                  Text('Xuất Kho CSKB Cho Cá Nhân'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Thông Tin Tồn Kho Hiện Tại
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isOverStock ? AppTheme.dangerRed : AppTheme.primaryGold.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TỒN KHO CSKB HIỆN TẠI:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  '$stockPacks gói x999 + $stockLoose viên lẻ',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                ),
                                Text(
                                  'Tổng: ${CurrencyFormatter.formatNumber(stock)} viên',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('TỒN SAU KHI XUẤT:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  '${CurrencyFormatter.formatNumber(remainingAfter)} viên',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isOverStock ? AppTheme.dangerRed : AppTheme.successGreen,
                                  ),
                                ),
                                Text(
                                  '${remainingAfter ~/ AppConstants.packSize} gói + ${remainingAfter % AppConstants.packSize} lẻ',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (isOverStock) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '⚠️ Cảnh báo: Số lượng xuất dùng vượt quá tồn kho hiện tại!',
                          style: TextStyle(color: AppTheme.dangerRed, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Nút chọn nhanh tiện lợi
                      const Text('Chọn nhanh số lượng xuất:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (stockPacks >= 1)
                            ActionChip(
                              avatar: const Icon(Icons.inventory_2, size: 14, color: AppTheme.primaryGold),
                              label: const Text('1 Gói (x999)'),
                              onPressed: () {
                                setState(() {
                                  packController.text = '1';
                                  looseController.text = '0';
                                });
                              },
                            ),
                          if (stockPacks >= 5)
                            ActionChip(
                              avatar: const Icon(Icons.inventory_2, size: 14, color: AppTheme.primaryGold),
                              label: const Text('5 Gói'),
                              onPressed: () {
                                setState(() {
                                  packController.text = '5';
                                  looseController.text = '0';
                                });
                              },
                            ),
                          if (stockLoose > 0)
                            ActionChip(
                              avatar: const Icon(Icons.pie_chart, size: 14, color: AppTheme.kiCyan),
                              label: Text('Toàn bộ viên lẻ ($stockLoose)'),
                              onPressed: () {
                                setState(() {
                                  packController.text = '0';
                                  looseController.text = stockLoose.toString();
                                });
                              },
                            ),
                          if (stock > 0)
                            ActionChip(
                              avatar: const Icon(Icons.all_inclusive, size: 14, color: Colors.purpleAccent),
                              label: const Text('Xuất toàn bộ kho'),
                              onPressed: () {
                                setState(() {
                                  packController.text = stockPacks.toString();
                                  looseController.text = stockLoose.toString();
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Số gói và số viên lẻ
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Số gói x999 muốn dùng:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: packController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: '0',
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
                                  controller: looseController,
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
                      const SizedBox(height: 16),

                      // Mục đích sử dụng
                      const Text('Mục đích sử dụng:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: purposeController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Mở Cải trang Dracula, Mở Đồ sao, Dịch chuyển...',
                          prefixIcon: Icon(Icons.flag_outlined, color: Colors.purpleAccent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          'Mở Cải trang Dracula',
                          'Mở Cải trang Vô Hình',
                          'Mở Đồ sao / Trang bị',
                          'Mở Kiếm Vàng & Đậu thần',
                          'Dịch chuyển tức thời',
                        ].map((p) {
                          return InkWell(
                            onTap: () => setState(() => purposeController.text = p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(p, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Nhân vật & Server
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tên nhân vật sử dụng:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: characterController,
                                  decoration: const InputDecoration(hintText: 'Ví dụ: Nick chính, Goku...'),
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
                                  decoration: const InputDecoration(hintText: 'Vũ trụ 1'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Thời gian
                      const Text('Thời gian xuất dùng:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Icon(Icons.calendar_today, size: 16, color: Colors.purpleAccent),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ghi chú kết quả mở
                      const Text('Ghi chú / Kết quả mở (nếu có):', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Mở được Cải trang Dracula 30 ngày, 3 đồ sao...',
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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (totalWanted <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập số gói x999 hoặc số viên lẻ lớn hơn 0!')),
                      );
                      return;
                    }

                    final usage = CskbUsage(
                      id: const Uuid().v4(),
                      packCount: packs,
                      looseCount: loose,
                      purpose: purposeController.text.trim().isNotEmpty ? purposeController.text.trim() : 'Sử dụng cá nhân',
                      characterName: characterController.text.trim(),
                      server: serverController.text.trim().isNotEmpty ? serverController.text.trim() : 'Vũ trụ 1',
                      createdAt: selectedDateTime,
                      note: noteController.text.trim(),
                    );

                    provider.addCskbUsage(usage);
                    Navigator.of(dialogCtx).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xuất dùng thành công ${CurrencyFormatter.formatNumber(totalWanted)} viên CSKB!')),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Xác Nhận Xuất Dùng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSession(BuildContext context, String id) {
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

  void _confirmDeleteUsage(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa lượt dùng'),
        content: const Text('Bạn có chắc chắn muốn xóa lượt xuất dùng cá nhân này? Toàn bộ số lượng CSKB sẽ được hoàn trả lại vào kho tồn.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AppProvider>().deleteCskbUsage(id);
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Xóa & Hoàn Kho'),
          ),
        ],
      ),
    );
  }
}
