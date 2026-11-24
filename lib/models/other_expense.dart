class OtherExpense {
  final String id;
  final String title; // Tên chi phí: Bùa dẻo dai, bùa thu hút, VPS, điện...
  final double amount; // Số tiền
  final String currency; // 'VND' hoặc 'TV'
  final DateTime createdAt; // Ngày giờ chi tiết
  final String? note; // Ghi chú

  OtherExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'note': note ?? '',
    };
  }

  factory OtherExpense.fromMap(Map<String, dynamic> map) {
    return OtherExpense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      note: map['note'] as String?,
    );
  }
}
