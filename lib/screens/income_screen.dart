import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/transaction_item.dart';
import '../providers/admin_provider.dart';
import '../services/printer_service.dart';
import '../services/transaction_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/printer_dialog.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _txService = TransactionService();
  String _selectedStatusFilter = 'Semua';

  void _showAdminLoginDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFF2D5A27)),
            SizedBox(width: 8),
            Text('Login Admin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan PIN khusus Admin Cikang Outdoor untuk mengakses laporan pendapatan:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                final success = context.read<AdminProvider>().login(pinController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Selamat datang di Menu Pendapatan!' : 'PIN Admin salah! Silakan coba lagi.'),
                    backgroundColor: success ? const Color(0xFF2D5A27) : Colors.red,
                  ),
                );
              },
              decoration: const InputDecoration(
                hintText: 'PIN Admin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5A27),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final success =
                  context.read<AdminProvider>().login(pinController.text);
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selamat datang di Menu Pendapatan!'),
                    backgroundColor: Color(0xFF2D5A27),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN Admin salah! Silakan coba lagi.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }

  void _showAddManualTransactionDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final itemsCtrl = TextEditingController();
    int duration = 2;
    DateTime startDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_shopping_cart, color: Color(0xFF2D5A27)),
                    SizedBox(width: 8),
                    Text(
                      'Catat Sewa / Pemasukan Manual',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Penyewa *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. WhatsApp *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: itemsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alat yang Disewa *',
                    hintText: 'Contoh: Tenda Dome (1x), Kompor (1x)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Biaya (Rp) *',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: duration,
                        decoration: const InputDecoration(
                          labelText: 'Durasi',
                          border: OutlineInputBorder(),
                        ),
                        items: [1, 2, 3, 4, 5, 7, 10].map((d) {
                          return DropdownMenuItem(value: d, child: Text('$d Hari'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => duration = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A27),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Simpan Transaksi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      final items = itemsCtrl.text.trim();
                      final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;

                      if (name.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama dan total biaya wajib diisi!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final messenger = ScaffoldMessenger.of(context);
                      await _txService.addTransaction(
                        TransactionItem(
                          id: '',
                          customerName: name,
                          customerPhone: phone,
                          totalAmount: amount,
                          rentStartDate: startDate,
                          durationDays: duration,
                          itemsSummary: items.isEmpty ? 'Alat Camping' : items,
                          status: 'Aktif',
                          createdAt: DateTime.now(),
                        ),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Transaksi sewa berhasil dicatat!'),
                            backgroundColor: Color(0xFF2D5A27),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone =
        cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : cleanPhone;
    final uri = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AdminProvider>().isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: const Text(
          'Pendapatan & Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Printer Bluetooth Thermal',
              onPressed: () => PrinterDialog.show(context),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Catat Transaksi Manual',
              onPressed: _showAddManualTransactionDialog,
            ),
          ],
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2D5A27),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Catat Sewa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _showAddManualTransactionDialog,
            )
          : null,
      body: !isAdmin
          // Tampilan jika belum login admin
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5A27).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_person_outlined,
                        size: 72,
                        color: Color(0xFF2D5A27),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Laporan Pendapatan & Keuangan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Menu ini dikhususkan bagi Admin / Pemilik Cikang Outdoor untuk memantau omset sewa, riwayat transaksi, dan status pengembalian alat.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A27),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Masuk sebagai Admin',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _showAdminLoginDialog,
                    ),
                  ],
                ),
              ),
            )
          // Tampilan Dashboard jika sudah login admin
          : StreamBuilder<List<TransactionItem>>(
              stream: _txService.getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D5A27)),
                  );
                }

                final transactions = snapshot.data ?? [];

                // Hitung metrik keuangan
                int totalSelesai = 0;
                int totalAktif = 0;
                int countSelesai = 0;
                int countAktif = 0;

                for (final tx in transactions) {
                  if (tx.status == 'Selesai') {
                    totalSelesai += tx.totalAmount;
                    countSelesai++;
                  } else if (tx.status == 'Aktif') {
                    totalAktif += tx.totalAmount;
                    countAktif++;
                  }
                }

                // Filter berdasarkan status
                final filtered = transactions.where((tx) {
                  if (_selectedStatusFilter == 'Semua') return true;
                  return tx.status == _selectedStatusFilter;
                }).toList();

                return Column(
                  children: [
                    // Kartu Ringkasan Pendapatan
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D5A27),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PENDAPATAN MASUK (LUNAS)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.format(totalSelesai),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Potensi Berjalan
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.hourglass_top,
                                            size: 14,
                                            color: Color(0xFFF39C12),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Sedang Disewa',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.format(totalAktif),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$countAktif Transaksi',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Transaksi Selesai
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 14,
                                            color: Colors.lightGreenAccent,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Sewa Selesai',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$countSelesai Order',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Telah dikembalikan',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Filter Status
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: ['Semua', 'Aktif', 'Selesai', 'Batal'].map(
                          (status) {
                            final isSel = _selectedStatusFilter == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: isSel,
                                selectedColor: const Color(0xFF2D5A27),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                onSelected: (_) {
                                  setState(
                                    () => _selectedStatusFilter = status,
                                  );
                                },
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),

                    // Daftar Transaksi
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada transaksi sewa',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pesanan pelanggan atau input manual akan muncul di sini',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final tx = filtered[index];
                                final isAktif = tx.status == 'Aktif';

                                return Card(
                                  elevation: 1.5,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header Kartu
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                      Color(0xFFE8F5E9),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 18,
                                                    color: Color(0xFF2D5A27),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  tx.customerName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Badge Status
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isAktif
                                                    ? const Color(0xFFFFF3CD)
                                                    : (tx.status == 'Selesai'
                                                        ? const Color(0xFFD4EDDA)
                                                        : const Color(0xFFF8D7DA)),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                tx.status,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isAktif
                                                      ? const Color(0xFF856404)
                                                      : (tx.status == 'Selesai'
                                                          ? const Color(0xFF155724)
                                                          : const Color(0xFF721C24)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 18),
                                        // Rincian Alat
                                        Text(
                                          tx.itemsSummary,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade800,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Tanggal & Nominal
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 13,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${tx.rentStartDate.day}/${tx.rentStartDate.month}/${tx.rentStartDate.year} (${tx.durationDays} Hari)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              CurrencyFormatter.format(
                                                tx.totalAmount,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFD35400),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Tombol Aksi
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (tx.customerPhone.isNotEmpty)
                                              TextButton.icon(
                                                onPressed: () =>
                                                    _openWhatsApp(tx.customerPhone),
                                                icon: const Icon(
                                                  Icons.chat,
                                                  size: 14,
                                                  color: Colors.green,
                                                ),
                                                label: const Text(
                                                  'WA',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            TextButton.icon(
                                              onPressed: () async {
                                                final connected =
                                                    await PrinterService()
                                                        .isConnected();
                                                if (connected) {
                                                  final printed =
                                                      await PrinterService()
                                                          .printRentalReceipt(tx);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          printed
                                                              ? 'Struk sewa berhasil dicetak! 🖨️'
                                                              : 'Gagal mencetak struk',
                                                        ),
                                                        backgroundColor: printed
                                                            ? const Color(0xFF2D5A27)
                                                            : Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  if (context.mounted) {
                                                    PrinterDialog.show(
                                                      context,
                                                      transaction: tx,
                                                    );
                                                  }
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.print,
                                                size: 14,
                                                color: Color(0xFF2D5A27),
                                              ),
                                              label: const Text(
                                                'Cetak',
                                                style: TextStyle(
                                                  color: Color(0xFF2D5A27),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            if (isAktif)
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF2D5A27),
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                ),
                                                label: const Text(
                                                  'Tandai Selesai',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await _txService.updateStatus(
                                                    tx.id,
                                                    'Selesai',
                                                  );
                                                },
                                              ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                              tooltip: 'Hapus Transaksi',
                                              onPressed: () async {
                                                await _txService.deleteTransaction(
                                                  tx.id,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
