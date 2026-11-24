class FarmingSession {
  final String id;
  final int detectorsUsed; // Số máy dò đã sử dụng
  final int cskbCollected; // Số viên CSKB nhặt được
  final String server; // Server / Vũ trụ
  final String accountName; // Tên nhân vật / tài khoản
  final DateTime createdAt; // Ngày giờ bắt đầu / ghi nhận
  final String? note; // Ghi chú map, đệ tử, bùa...

  FarmingSession({
    required this.id,
    required this.detectorsUsed,
    required this.cskbCollected,
    this.server = 'Vũ trụ 1',
    this.accountName = '',
    required this.createdAt,
    this.note,
  });

  // Tỷ lệ rơi trung bình: số CSKB trên 1 máy dò
  double get dropRate =>
      detectorsUsed > 0 ? cskbCollected / detectorsUsed : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'detectors_used': detectorsUsed,
      'cskb_collected': cskbCollected,
      'server': server,
      'account_name': accountName,
      'created_at': createdAt.toIso8601String(),
      'note': note ?? '',
    };
  }

  factory FarmingSession.fromMap(Map<String, dynamic> map) {
    return FarmingSession(
      id: map['id'] as String,
      detectorsUsed: map['detectors_used'] as int,
      cskbCollected: map['cskb_collected'] as int,
      server: (map['server'] as String?) ?? 'Vũ trụ 1',
      accountName: (map['account_name'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      note: map['note'] as String?,
    );
  }
}
