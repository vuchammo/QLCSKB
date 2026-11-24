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

  // Cài đặt Đồng bộ Cloud / Đội nhóm
  static const String settingSupabaseUrl = 'supabase_url';
  static const String settingSupabaseAnonKey = 'supabase_anon_key';
  static const String settingCurrentTeamCode = 'current_team_code';
  static const String settingCurrentTeamName = 'current_team_name';
  static const String settingMemberName = 'member_name';

  // Tỷ giá mặc định: 1 Thỏi Vàng = 350 VND (có thể tùy chỉnh)
  static const double defaultTvToVndRate = 350.0;
}
