import '../core/constants/app_constants.dart';

class CskbUsage {
  final String id;
  final int packCount; // Số gói x999 sử dụng
  final int looseCount; // Số viên lẻ sử dụng
  final String purpose; // Mục đích sử dụng (vd: Mở Cải trang Dracula, Mở Đồ sao, Dịch chuyển...)
  final String? characterName; // Tên nhân vật mở/dùng
  final String server; // Server / Vũ trụ
  final DateTime createdAt; // Thời gian chi tiết
  final String? note; // Ghi chú kết quả mở đồ

  CskbUsage({
    required this.id,
    this.packCount = 0,
    this.looseCount = 0,
    required this.purpose,
    this.characterName,
    this.server = AppConstants.defaultServer,
    required this.createdAt,
    this.note,
  });

  /// Tổng số viên CSKB đã lấy ra dùng cá nhân
  int get totalCskb => (packCount * AppConstants.packSize) + looseCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pack_count': packCount,
      'loose_count': looseCount,
      'purpose': purpose,
      'character_name': characterName,
      'server': server,
      'created_at': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory CskbUsage.fromMap(Map<String, dynamic> map) {
    return CskbUsage(
      id: map['id'] as String,
      packCount: (map['pack_count'] as num?)?.toInt() ?? 0,
      looseCount: (map['loose_count'] as num?)?.toInt() ?? 0,
      purpose: (map['purpose'] as String?) ?? 'Sử dụng cá nhân',
      characterName: map['character_name'] as String?,
      server: (map['server'] as String?) ?? AppConstants.defaultServer,
      createdAt: DateTime.parse(map['created_at'] as String),
      note: map['note'] as String?,
    );
  }

  CskbUsage copyWith({
    String? id,
    int? packCount,
    int? looseCount,
    String? purpose,
    String? characterName,
    String? server,
    DateTime? createdAt,
    String? note,
  }) {
    return CskbUsage(
      id: id ?? this.id,
      packCount: packCount ?? this.packCount,
      looseCount: looseCount ?? this.looseCount,
      purpose: purpose ?? this.purpose,
      characterName: characterName ?? this.characterName,
      server: server ?? this.server,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }
}
