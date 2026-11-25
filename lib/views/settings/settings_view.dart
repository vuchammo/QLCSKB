import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/other_expense.dart';
import 'widgets/update_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _rateController;
  late TextEditingController _serverController;
  late TextEditingController _repoController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _rateController = TextEditingController(text: provider.exchangeRateTvToVnd.toString());
    _serverController = TextEditingController(text: provider.defaultServer);
    _repoController = TextEditingController(text: provider.githubRepo);
  }

  @override
  void dispose() {
    _rateController.dispose();
    _serverController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Cài Đặt & Chi Phí Vận Hành',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tùy chỉnh tỷ giá Thỏi Vàng và theo dõi các chi phí phụ (bùa, VPS, đậu thần...)',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),

            // Card 1: Cài đặt tỷ giá
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune, color: AppTheme.primaryGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cài Đặt Tỷ Giá Quy Đổi Thỏi Vàng (TV) / VND',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tỷ giá này dùng để quy đổi đồng bộ trong các báo cáo Lời Lỗ và Dashboard',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        const Text(
                          '1 Thỏi Vàng (TV) =',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 180,
                          child: TextField(
                            controller: _rateController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              suffixText: 'VND',
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final newRate = double.tryParse(_rateController.text.trim()) ?? 0.0;
                            if (newRate > 0) {
                              provider.updateExchangeRate(newRate);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã cập nhật tỷ giá: 1 TV = $newRate đ')),
                              );
                            }
                          },
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Lưu Tỷ Giá'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card: Cài đặt Server mặc định
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.public, color: AppTheme.kiCyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cài Đặt Server / Vũ Trụ Mặc Định',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Server này sẽ được tự động điền sẵn khi bạn ghi ca up, xuất dùng cá nhân hoặc tạo đơn bán',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: _serverController,
                            decoration: const InputDecoration(
                              hintText: 'Ví dụ: Server 15',
                              prefixIcon: Icon(Icons.dns_outlined, size: 18, color: AppTheme.kiCyan),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.kiCyan, foregroundColor: Colors.black),
                          onPressed: () {
                            final server = _serverController.text.trim();
                            if (server.isNotEmpty) {
                              provider.updateDefaultServer(server);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã cập nhật Server mặc định: $server')),
                              );
                            }
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Lưu Server'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Chọn nhanh các server:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: AppConstants.serverList.take(8).map((s) {
                        final isSelected = provider.defaultServer == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSelected,
                          selectedColor: AppTheme.kiCyan.withOpacity(0.2),
                          onSelected: (_) {
                            setState(() => _serverController.text = s);
                            provider.updateDefaultServer(s);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã chọn Server mặc định: $s')),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card 2: Chi phí phụ (Bùa, VPS, đậu...)
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
                            Icon(Icons.shopping_bag_outlined, color: AppTheme.dangerRed, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Chi Phí Vận Hành Phụ (Bùa, Thuê VPS, Điện...)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.borderDark, foregroundColor: Colors.white),
                          onPressed: () => _showAddExpenseDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm Chi Phí'),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    if (provider.otherExpenses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Chưa có chi phí phụ nào được ghi nhận.\n(Ví dụ: tiền mua bùa dẻo dai, bùa thu hút, tiền VPS...)',
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
                            DataColumn(label: Text('Thời Gian', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Khoản Chi', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Số Tiền', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Ghi Chú', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.otherExpenses.map((exp) {
                            return DataRow(
                              cells: [
                                DataCell(Text(DateFormatter.formatFull(exp.createdAt))),
                                DataCell(Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(
                                  Text(
                                    CurrencyFormatter.format(exp.amount, currency: exp.currency),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.dangerRed),
                                  ),
                                ),
                                DataCell(Text(exp.note?.isNotEmpty == true ? exp.note! : '---')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerRed),
                                    onPressed: () {
                                      provider.deleteOtherExpense(exp.id);
                                    },
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

            const SizedBox(height: 24),

            // Card 3: Thông tin ứng dụng & Cập nhật phiên bản
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.kiCyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.system_update_alt, color: AppTheme.kiCyan, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    AppConstants.appTitle,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Text(
                                      'v${provider.currentAppVersion}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nền tảng: ${kIsWeb ? "Web" : (Platform.isWindows ? "Windows Desktop" : (Platform.isMacOS ? "macOS Desktop" : "Desktop"))} • Cơ sở dữ liệu SQLite cục bộ (Offline-first)',
                                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: provider.availableUpdate?.hasUpdate == true
                                ? AppTheme.primaryOrange
                                : AppTheme.cardDark,
                            foregroundColor: provider.availableUpdate?.hasUpdate == true
                                ? Colors.black
                                : Colors.white,
                            side: const BorderSide(color: AppTheme.primaryGold),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: provider.isCheckingUpdate
                              ? null
                              : () async {
                                  final info = await provider.checkForUpdate(manual: true);
                                  if (!context.mounted) return;
                                  if (info != null && info.hasUpdate) {
                                    UpdateDialog.show(
                                      context,
                                      updateInfo: info,
                                      updateService: provider.updateService,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Bạn đang sử dụng phiên bản mới nhất (v${provider.currentAppVersion})!'),
                                        backgroundColor: AppTheme.successGreen,
                                      ),
                                    );
                                  }
                                },
                          icon: provider.isCheckingUpdate
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold),
                                )
                              : Icon(
                                  provider.availableUpdate?.hasUpdate == true
                                      ? Icons.rocket_launch
                                      : Icons.refresh,
                                  size: 18,
                                ),
                          label: Text(
                            provider.isCheckingUpdate
                                ? 'Đang kiểm tra...'
                                : (provider.availableUpdate?.hasUpdate == true
                                    ? 'Có Bản Mới: v${provider.availableUpdate!.latestVersion}'
                                    : 'Kiểm Tra Cập Nhật'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28, color: AppTheme.borderDark),

                    // Tùy chọn Tự động kiểm tra & Cấu hình Repo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tự động kiểm tra bản cập nhật khi mở app',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Ứng dụng sẽ thông báo khi phát hiện bản phát hành mới trên GitHub',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        Switch(
                          value: provider.autoCheckUpdate,
                          activeColor: AppTheme.primaryGold,
                          onChanged: (val) {
                            provider.updateAutoCheckUpdate(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Cấu hình nâng cao: Kho lưu trữ GitHub (Repository)',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _repoController,
                                  decoration: const InputDecoration(
                                    labelText: 'GitHub Repository (owner/repo)',
                                    hintText: AppConstants.defaultGithubRepo,
                                    prefixIcon: Icon(Icons.code, size: 18, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final repo = _repoController.text.trim();
                                  if (repo.isNotEmpty) {
                                    provider.updateGithubRepo(repo);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã cập nhật kho lưu trữ: $repo')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.save, size: 16),
                                label: const Text('Lưu Kho'),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCurrency = AppConstants.currencyVnd;
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm Khoản Chi Phí Phụ'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tên khoản chi:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Ví dụ: Bùa thu hút 1 tháng, Tiền VPS...'),
                ),
                const SizedBox(height: 16),
                const Text('Số tiền:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Ví dụ: 50000', suffixText: 'VND'),
                ),
                const SizedBox(height: 16),
                const Text('Ghi chú:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(hintText: 'Tùy chọn'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim().replaceAll(',', '')) ?? 0.0;
                final title = titleController.text.trim();
                if (title.isEmpty || amount <= 0) {
                  return;
                }
                final exp = OtherExpense(
                  id: const Uuid().v4(),
                  title: title,
                  amount: amount,
                  currency: selectedCurrency,
                  createdAt: selectedDateTime,
                  note: noteController.text.trim(),
                );
                context.read<AppProvider>().addOtherExpense(exp);
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}
