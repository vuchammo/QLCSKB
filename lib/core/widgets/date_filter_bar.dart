import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/theme/app_theme.dart';

class DateFilterBar extends StatelessWidget {
  const DateFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentMode = provider.dateFilterMode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Kỳ báo cáo:',
            style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(context, 'Tất cả thời gian', DateFilterMode.all, currentMode),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Hôm nay', DateFilterMode.today, currentMode),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Hôm qua', DateFilterMode.yesterday, currentMode),
          const SizedBox(width: 8),
          _buildFilterChip(context, '7 ngày qua', DateFilterMode.thisWeek, currentMode),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Tháng này', DateFilterMode.thisMonth, currentMode),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    DateFilterMode mode,
    DateFilterMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGold,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: AppTheme.cardDark,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryGold : AppTheme.borderDark,
      ),
      onSelected: (_) {
        context.read<AppProvider>().setDateFilter(mode);
      },
    );
  }
}
