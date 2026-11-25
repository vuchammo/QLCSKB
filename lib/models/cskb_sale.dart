import '../core/constants/app_constants.dart';

class CskbSale {
  final String id;
  final int packCount; // Số gói x999 bán
  final int looseCount; // Số lượng viên lẻ kèm theo (nếu có)
  final double unitPricePerPack; // Đơn giá mỗi gói x999
  final double totalRevenue; // Tổng tiền thu được
  final String currency; // 'VND' hoặc 'TV'
  final String customerName; // Tên khách hàng / Nick người mua
  final String server; // Server giao dịch
  final DateTime createdAt; // Ngày giờ bán chi tiết
  final String status; // 'PAID' (Đã thanh toán) hoặc 'DEBT' (Ghi nợ)
  final String? note; // Ghi chú

  CskbSale({
    required this.id,
    required this.packCount,
    this.looseCount = 0,
    required this.unitPricePerPack,
    required this.totalRevenue,
    required this.currency,
    this.customerName = '',
    this.server = AppConstants.defaultServer,
    required this.createdAt,
    this.status = 'PAID',
    this.note,
  });

  // Tổng số viên CSKB đã bán trong đơn này
  int get totalCskb => (packCount * AppConstants.packSize) + looseCount;

  bool get isPaid => status == 'PAID';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pack_count': packCount,
      'loose_count': looseCount,
      'unit_price_per_pack': unitPricePerPack,
      'total_revenue': totalRevenue,
      'currency': currency,
      'customer_name': customerName,
      'server': server,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'note': note ?? '',
    };
  }

  factory CskbSale.fromMap(Map<String, dynamic> map) {
    return CskbSale(
      id: map['id'] as String,
      packCount: map['pack_count'] as int,
      looseCount: (map['loose_count'] as int?) ?? 0,
      unitPricePerPack: (map['unit_price_per_pack'] as num).toDouble(),
      totalRevenue: (map['total_revenue'] as num).toDouble(),
      currency: map['currency'] as String,
      customerName: (map['customer_name'] as String?) ?? '',
      server: (map['server'] as String?) ?? AppConstants.defaultServer,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: (map['status'] as String?) ?? 'PAID',
      note: map['note'] as String?,
    );
  }
}
