import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/calculation_service.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  // Bộ tính 1: Viên sang Gói x999
  final _cskbInputController = TextEditingController(text: '2500');
  final _packPriceController = TextEditingController(text: '40000');

  // Bộ tính 2: Gói sang Viên
  final _packInputController = TextEditingController(text: '5');
  final _looseInputController = TextEditingController(text: '0');

  // Bộ tính 3: Thỏi Vàng sang VND
  final _tvInputController = TextEditingController(text: '100');
  final _vndInputController = TextEditingController(text: '35000');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final exchangeRate = provider.exchangeRateTvToVnd;

    // Tính toán bộ 1
    final inputCskb = int.tryParse(_cskbInputController.text.trim()) ?? 0;
    final packPrice = double.tryParse(_packPriceController.text.trim().replaceAll(',', '')) ?? 0.0;
    final packsCalculated = CalculationService.cskbToPacks(inputCskb);
    final looseCalculated = CalculationService.cskbToLoose(inputCskb);
    final totalMoneyFromPacks = (packsCalculated * packPrice) + (looseCalculated > 0 ? (looseCalculated / AppConstants.packSize * packPrice) : 0.0);

    // Tính toán bộ 2
    final inputPacks = int.tryParse(_packInputController.text.trim()) ?? 0;
    final inputLoose = int.tryParse(_looseInputController.text.trim()) ?? 0;
    final totalCskbCalculated = CalculationService.packsAndLooseToCskb(inputPacks, inputLoose);

    // Tính toán bộ 3
    final inputTv = double.tryParse(_tvInputController.text.trim()) ?? 0.0;
    final convertedVndFromTv = inputTv * exchangeRate;

    final inputVnd = double.tryParse(_vndInputController.text.trim().replaceAll(',', '')) ?? 0.0;
    final convertedTvFromVnd = exchangeRate > 0 ? (inputVnd / exchangeRate) : 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Máy Tính Nhanh CSKB & Quy Đổi Gói x999',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Công cụ tính nhanh quy đổi số lượng Capsule Kì Bí sang gói x999, giá tiền và tỷ giá Thỏi Vàng',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),

            // Lưới các công cụ tính toán (Tự co giãn 1 cột hoặc 2 cột theo độ rộng màn hình)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                final card1 = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calculate, color: AppTheme.primaryOrange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Quy Đổi Viên Lẻ Sang Gói x999',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppTheme.borderDark),

                        const Text('Nhập tổng số viên CSKB:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _cskbInputController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Ví dụ: 2500',
                            suffixText: 'viên',
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text('Giá bán 1 gói x999 CSKB (VND):', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _packPriceController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Ví dụ: 40000',
                            suffixText: 'đ / gói',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Kết quả
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('KẾT QUẢ QUY ĐỔI:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  const Icon(Icons.inventory_2, color: AppTheme.primaryGold, size: 24),
                                  Text(
                                    '$packsCalculated gói x999',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                  ),
                                  Text(
                                    '+ $looseCalculated viên lẻ',
                                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, color: AppTheme.borderDark),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  const Text('Ước tính thành tiền:', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    CurrencyFormatter.format(totalMoneyFromPacks),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.successGreen,
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
                );

                final card2 = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.inventory, color: AppTheme.kiCyan, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Quy Đổi Số Gói x999 Sang Tổng Viên',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppTheme.borderDark),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Số gói x999:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _packInputController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: '5',
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
                                    controller: _looseInputController,
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
                        const SizedBox(height: 20),

                        // Kết quả
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.kiCyan.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TỔNG SỐ LƯỢNG CSKB:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  const Icon(Icons.auto_awesome, color: AppTheme.kiCyan, size: 24),
                                  Text(
                                    '${CurrencyFormatter.formatNumber(totalCskbCalculated)} viên',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.kiCyan),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '($inputPacks x 999 + $inputLoose viên = $totalCskbCalculated viên CSKB)',
                                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 16),
                      Expanded(child: card2),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      card1,
                      const SizedBox(height: 16),
                      card2,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Card Quy đổi Tỷ Giá Thỏi Vàng <-> VND
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideHeader = constraints.maxWidth > 550;
                        if (isWideHeader) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.currency_exchange, color: AppTheme.primaryGold, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Quy Đổi Tỷ Giá Thỏi Vàng (TV) & VND',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                'Tỷ giá: 1 TV = ${CurrencyFormatter.formatNumber(exchangeRate)} đ',
                                style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.currency_exchange, color: AppTheme.primaryGold, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Quy Đổi Tỷ Giá TV & VND',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tỷ giá: 1 TV = ${CurrencyFormatter.formatNumber(exchangeRate)} đ',
                                style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const Divider(height: 24, color: AppTheme.borderDark),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideInputs = constraints.maxWidth > 600;

                        final colTvToVnd = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Đổi từ Thỏi Vàng sang VND:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _tvInputController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: '100',
                                suffixText: 'Thỏi Vàng',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.bgDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '= ${CurrencyFormatter.format(convertedVndFromTv)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                              ),
                            ),
                          ],
                        );

                        final colVndToTv = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Đổi từ VND sang Thỏi Vàng:', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _vndInputController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: '35000',
                                suffixText: 'VND',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.bgDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '= ${CurrencyFormatter.formatDecimal(convertedTvFromVnd)} Thỏi Vàng',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                              ),
                            ),
                          ],
                        );

                        if (isWideInputs) {
                          return Row(
                            children: [
                              Expanded(child: colTvToVnd),
                              const SizedBox(width: 24),
                              Expanded(child: colVndToTv),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              colTvToVnd,
                              const SizedBox(height: 20),
                              colVndToTv,
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
}
