import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'dashboard/dashboard_view.dart';
import 'detector/detector_view.dart';
import 'farming/farming_view.dart';
import 'sales/sales_view.dart';
import 'reports/reports_view.dart';
import 'calculator/calculator_view.dart';
import 'sync/team_sync_view.dart';
import 'settings/settings_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardView(),
    DetectorView(),
    FarmingView(),
    SalesView(),
    ReportsView(),
    CalculatorView(),
    TeamSyncView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryGold),
              SizedBox(height: 16),
              Text('Đang tải dữ liệu Up CSKB...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar bên trái
          Container(
            width: 245,
            decoration: const BoxDecoration(
              color: Color(0xFF141E33),
              border: Border(
                right: BorderSide(color: AppTheme.borderDark, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo & Header thương hiệu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.flash_on, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QLCSKB',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Ngọc Rồng Online',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Trạng thái Team online badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 6; // Chuyển sang tab Đội nhóm
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: provider.isOnlineMode
                            ? AppTheme.successGreen.withOpacity(0.12)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: provider.isOnlineMode
                              ? AppTheme.successGreen.withOpacity(0.5)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: provider.isOnlineMode ? AppTheme.successGreen : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.isOnlineMode
                                  ? 'Nhóm: ${provider.currentTeamCode}'
                                  : 'Chế độ: Cục bộ (Offline)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: provider.isOnlineMode ? AppTheme.successGreen : Colors.grey[400],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, color: AppTheme.borderDark),
                const SizedBox(height: 12),

                // Danh sách Menu
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      _buildMenuItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Tổng Quan'),
                      _buildMenuItem(1, Icons.radar_outlined, Icons.radar, 'Máy Dò'),
                      _buildMenuItem(2, Icons.inventory_2_outlined, Icons.inventory_2, 'Kho CSKB & Ca Up'),
                      _buildMenuItem(3, Icons.point_of_sale_outlined, Icons.point_of_sale, 'Bán Hàng x999'),
                      _buildMenuItem(4, Icons.query_stats_outlined, Icons.query_stats, 'Báo Cáo Lời / Lỗ'),
                      const Divider(height: 24, color: AppTheme.borderDark),
                      _buildMenuItem(5, Icons.calculate_outlined, Icons.calculate, 'Máy Tính CSKB'),
                      _buildMenuItem(
                        6,
                        Icons.cloud_sync_outlined,
                        Icons.cloud_sync,
                        'Đội Nhóm Online',
                        badgeText: provider.isOnlineMode ? 'LIVE' : null,
                      ),
                      _buildMenuItem(7, Icons.settings_outlined, Icons.settings, 'Cài Đặt & Chi Phí'),
                    ],
                  ),
                ),

                // Thông tin phiên bản chân trang
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        provider.isOnlineMode
                            ? 'v${AppConstants.version} Cloud Sync'
                            : 'v${AppConstants.version} Offline DB',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Màn hình nội dung chính bên phải
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String title, {
    String? badgeText,
  }) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryGold.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: AppTheme.primaryGold.withOpacity(0.5))
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? AppTheme.primaryGold : Colors.grey[400],
          size: 20,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGold : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
