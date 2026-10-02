import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/dummy_gear.dart';
import '../models/gear_item.dart';

class GearService {
  final CollectionReference _gearsRef =
      FirebaseFirestore.instance.collection('gears');

  /// Mendengarkan perubahan data alat sewa secara real-time dari Firestore
  Stream<List<GearItem>> getGearsStream() {
    return _gearsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return GearItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Menambah alat baru ke Firestore
  Future<String> addGear(GearItem gear) async {
    final docRef = _gearsRef.doc();
    final map = gear.toMap();
    // Tunggu maksimal 6 detik untuk konfirmasi server.
    // Jika offline/lambat, Firestore tetap menyimpan ke cache lokal secara instan.
    await docRef.set(map).timeout(
      const Duration(seconds: 6),
      onTimeout: () => null,
    );
    return docRef.id;
  }

  /// Memperbarui data alat yang sudah ada
  Future<void> updateGear(GearItem gear) async {
    final docId = gear.id.trim().isNotEmpty ? gear.id.trim() : _gearsRef.doc().id;
    final docRef = _gearsRef.doc(docId);
    await docRef.set(gear.toMap(), SetOptions(merge: true)).timeout(
      const Duration(seconds: 6),
      onTimeout: () => null,
    );
  }

  /// Menghapus alat dari Firestore
  Future<void> deleteGear(String id) async {
    if (id.trim().isEmpty) return;
    await _gearsRef.doc(id).delete().timeout(
      const Duration(seconds: 6),
      onTimeout: () => null,
    );
  }

  /// Mengunggah data awal (dummyGears) ke Firestore jika database masih kosong
  Future<int> seedInitialData() async {
    try {
      final snapshot = await _gearsRef.limit(1).get().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw 'Koneksi ke Firestore lambat. Periksa internet.',
      );
      if (snapshot.docs.isNotEmpty) {
        return 0; // Sudah ada data
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final gear in dummyGears) {
        final newDoc = _gearsRef.doc(gear.id);
        batch.set(newDoc, gear.toMap());
      }
      await batch.commit().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw 'Waktu unggah habis. Silakan coba kembali.',
      );
      return dummyGears.length;
    } catch (_) {
      rethrow;
    }
  }

  /// Mengurangi stok alat saat ada yang menyewa
  Future<void> decreaseStock(String gearId, int quantity) async {
    try {
      final doc = await _gearsRef.doc(gearId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final currentStock = (data['stock'] as num?)?.toInt() ?? 5;
        final newStock = (currentStock - quantity).clamp(0, 9999);
        await _gearsRef.doc(gearId).update({
          'stock': newStock,
          'isAvailable': newStock > 0,
        });
      }
    } catch (_) {}
  }

  /// Menambah stok alat kembali saat masa sewa selesai
  Future<void> increaseStock(String gearId, int quantity) async {
    try {
      final doc = await _gearsRef.doc(gearId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final currentStock = (data['stock'] as num?)?.toInt() ?? 0;
        final newStock = currentStock + quantity;
        await _gearsRef.doc(gearId).update({
          'stock': newStock,
          'isAvailable': true,
        });
      }
    } catch (_) {}
  }
}
