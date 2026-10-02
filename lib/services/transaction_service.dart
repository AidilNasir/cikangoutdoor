import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_item.dart';

class TransactionService {
  final CollectionReference _txRef =
      FirebaseFirestore.instance.collection('transactions');

  /// Mendengarkan daftar transaksi secara real-time dari Firestore
  Stream<List<TransactionItem>> getTransactionsStream() {
    return _txRef.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return TransactionItem.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Urutkan dari yang paling baru
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Menambah transaksi / pesanan baru
  Future<String> addTransaction(TransactionItem item) async {
    final docRef = await _txRef.add(item.toMap());
    return docRef.id;
  }

  /// Mengubah status transaksi ('Aktif', 'Selesai', 'Batal')
  Future<void> updateStatus(String id, String newStatus) async {
    await _txRef.doc(id).update({'status': newStatus});
  }

  /// Menghapus transaksi
  Future<void> deleteTransaction(String id) async {
    await _txRef.doc(id).delete();
  }

  /// Mengisi data sampel jika baru pertama kali dipakai
  Future<void> seedSampleTransaction() async {
    final snapshot = await _txRef.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final sample1 = TransactionItem(
      id: '',
      customerName: 'Budi Santoso',
      customerPhone: '081234567890',
      totalAmount: 180000,
      rentStartDate: DateTime.now().subtract(const Duration(days: 1)),
      durationDays: 2,
      itemsSummary: 'Tenda Dome Arpenaz 4.1 (1x), Kompor Portabel (1x)',
      status: 'Selesai',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    final sample2 = TransactionItem(
      id: '',
      customerName: 'Rian Pratama',
      customerPhone: '082198765432',
      totalAmount: 90000,
      rentStartDate: DateTime.now(),
      durationDays: 2,
      itemsSummary: 'Carrier Deuter Aircontact 65+10L (1x)',
      status: 'Aktif',
      createdAt: DateTime.now(),
    );

    await _txRef.add(sample1.toMap());
    await _txRef.add(sample2.toMap());
  }
}
