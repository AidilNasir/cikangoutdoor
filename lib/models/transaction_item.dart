class TransactionItem {
  final String id;
  final String customerName;
  final String customerPhone;
  final int totalAmount;
  final DateTime rentStartDate;
  final int durationDays;
  final String itemsSummary;
  final String status; // 'Aktif' (Sedang Disewa), 'Selesai', 'Batal'
  final DateTime createdAt;

  TransactionItem({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.rentStartDate,
    required this.durationDays,
    required this.itemsSummary,
    this.status = 'Aktif',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'totalAmount': totalAmount,
      'rentStartDate': rentStartDate.toIso8601String(),
      'durationDays': durationDays,
      'itemsSummary': itemsSummary,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is String) {
        return DateTime.tryParse(val) ?? fallback;
      }
      return fallback;
    }

    return TransactionItem(
      id: docId,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toInt() ?? 0,
      rentStartDate: parseDate(map['rentStartDate'], DateTime.now()),
      durationDays: (map['durationDays'] as num?)?.toInt() ?? 1,
      itemsSummary: map['itemsSummary'] ?? '',
      status: map['status'] ?? 'Aktif',
      createdAt: parseDate(map['createdAt'], DateTime.now()),
    );
  }

  TransactionItem copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    int? totalAmount,
    DateTime? rentStartDate,
    int? durationDays,
    String? itemsSummary,
    String? status,
    DateTime? createdAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      rentStartDate: rentStartDate ?? this.rentStartDate,
      durationDays: durationDays ?? this.durationDays,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
