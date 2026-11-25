class AppConstants {
  static const int packSize = 999; // 1 gói CSKB = 999 viên
  static const String appTitle = 'Quản Lý Up CSKB - Ngọc Rồng Online';
  static const String version = '1.0.0';

  // Tiền tệ
  static const String currencyVnd = 'VND';
  static const String currencyThoiVang = 'TV'; // Thỏi Vàng

  // Khóa cài đặt
  static const String settingExchangeRateTvToVnd = 'exchange_rate_tv_to_vnd';
  static const String settingDefaultCurrency = 'default_currency';
  static const String settingDefaultServer = 'default_server';

  // Server mặc định & danh sách gợi ý
  static const String defaultServer = 'Server 15';
  static const List<String> serverList = [
    'Server 15',
    'Server 14',
    'Server 13',
    'Server 12',
    'Server 11',
    'Server 10',
    'Server 9',
    'Server 8',
    'Server 7',
    'Server 6',
    'Server 5',
    'Server 4',
    'Server 3',
    'Server 2',
    'Server 1',
  ];

  // Cài đặt Đồng bộ Cloud / Đội nhóm
  static const String settingSupabaseUrl = 'supabase_url';
  static const String settingSupabaseAnonKey = 'supabase_anon_key';
  static const String settingCurrentTeamCode = 'current_team_code';
  static const String settingCurrentTeamName = 'current_team_name';
  static const String settingMemberName = 'member_name';

  // Cài đặt Tự động Cập nhật
  static const String defaultGithubRepo = 'vuchammo/QLCSKB';
  static const String settingGithubRepo = 'github_repo';
  static const String settingAutoCheckUpdate = 'auto_check_update';
  static const String settingLastUpdateCheckTime = 'last_update_check_time';

  // Tỷ giá mặc định: 1 Thỏi Vàng = 350 VND (có thể tùy chỉnh)
  static const double defaultTvToVndRate = 350.0;
}
