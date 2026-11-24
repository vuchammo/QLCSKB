class DetectorPurchase {
  final String id;
  final int quantity; // Số lượng máy dò mua
  final double totalPrice; // Tổng tiền mua
  final String currency; // 'VND' hoặc 'TV'
  final DateTime createdAt; // Ngày giờ mua chi tiết
  final String? note; // Ghi chú (mua của ai, shop nào)

  DetectorPurchase({
    required this.id,
    required this.quantity,
    required this.totalPrice,
    required this.currency,
    required this.createdAt,
    this.note,
  });

  // Đơn giá trung bình 1 máy dò
  double get unitPrice => quantity > 0 ? totalPrice / quantity : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'total_price': totalPrice,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'note': note ?? '',
    };
  }

  factory DetectorPurchase.fromMap(Map<String, dynamic> map) {
    return DetectorPurchase(
      id: map['id'] as String,
      quantity: map['quantity'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      currency: map['currency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      note: map['note'] as String?,
    );
  }
}
