import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/transaction_item.dart';
import '../services/printer_service.dart';

class PrinterDialog extends StatefulWidget {
  final TransactionItem? transactionToPrint;

  const PrinterDialog({super.key, this.transactionToPrint});

  static Future<void> show(
    BuildContext context, {
    TransactionItem? transaction,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PrinterDialog(transactionToPrint: transaction),
    );
  }

  @override
  State<PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<PrinterDialog> {
  final _printerService = PrinterService();
  List<BluetoothInfo> _devices = [];
  bool _isLoading = true;
  bool _isConnected = false;
  bool _hasPermission = true;
  bool _isBluetoothOn = true;
  String? _connectingMac;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkStatusAndLoadDevices();
  }

  Future<void> _checkStatusAndLoadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Cek izin Bluetooth (Android 12+)
      final hasPerm = await _printerService.hasBluetoothPermission();
      if (!hasPerm) {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Cek status koneksi dan bluetooth
      final connected = await _printerService.isConnected();
      final isBtOn = await _printerService.isBluetoothEnabled();

      // 3. Ambil daftar perangkat yang dipasangkan
      final devices = await _printerService.getPairedPrinters();

      if (mounted) {
        setState(() {
          _hasPermission = true;
          _isConnected = connected;
          _isBluetoothOn = isBtOn;
          _devices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);
    final granted = await _printerService.requestPermissions();
    if (mounted) {
      setState(() => _hasPermission = granted);
      await _checkStatusAndLoadDevices();
    }
  }

  Future<void> _connectDevice(BluetoothInfo device) async {
    setState(() => _connectingMac = device.macAdress);
    try {
      final success = await _printerService.connect(device);
      if (!mounted) return;

      setState(() {
        _connectingMac = null;
        _isConnected = success;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terhubung ke ${device.name}!'),
            backgroundColor: const Color(0xFF2D5A27),
          ),
        );

        // Jika ada transaksi yang sedang menunggu dicetak, cetak langsung!
        if (widget.transactionToPrint != null) {
          final printed = await _printerService.printRentalReceipt(
            widget.transactionToPrint!,
          );
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  printed
                      ? 'Struk sewa berhasil dicetak! 🖨️'
                      : 'Gagal mencetak struk',
                ),
                backgroundColor:
                    printed ? const Color(0xFF2D5A27) : Colors.red,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal terhubung ke printer. Pastikan printer menyala & dekat.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _connectingMac = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kendala koneksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await _printerService.disconnect();
      if (mounted) {
        setState(() => _isConnected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer terputus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testPrint() async {
    try {
      final success = await _printerService.printTestReceipt();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Uji coba cetak berhasil!' : 'Gagal mencetak uji coba',
            ),
            backgroundColor: success ? const Color(0xFF2D5A27) : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal cetak: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSupported = _printerService.isSupportedPlatform;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.print_rounded, color: Color(0xFF2D5A27), size: 26),
                  SizedBox(width: 8),
                  Text(
                    'Printer Bluetooth Thermal',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Pindai Ulang',
                onPressed: _checkStatusAndLoadDevices,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Banner Mode Desktop / Web Simulasi
          if (!isSupported)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.laptop_chromebook, color: Color(0xFF1565C0), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mode Desktop / Web: Pencetakan fisik Bluetooth memerlukan HP Android. Di desktop fitur berjalan dalam mode simulasi.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF0D47A1),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Banner Izin Belum Diberikan (Android 12+)
          if (!_hasPermission && isSupported)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEEBA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: Color(0xFF856404), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Izin Bluetooth Diperlukan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF856404),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aplikasi memerlukan izin perangkat sekitar (Bluetooth Connect & Scan) untuk mendeteksi printer kasir Anda.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A27),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Beri Izin Bluetooth'),
                    onPressed: _requestPermission,
                  ),
                ],
              ),
            ),

          // Banner Bluetooth Mati
          if (!_isBluetoothOn && _hasPermission && isSupported)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE9E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCCBC)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bluetooth_disabled, color: Colors.deepOrange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bluetooth HP Anda belum aktif. Silakan hidupkan Bluetooth di pengaturan HP Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

          // Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isConnected
                  ? const Color(0xFFD4EDDA)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isConnected ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.bluetooth_searching,
                  color: _isConnected ? Colors.green : Colors.grey.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isConnected
                        ? 'Terhubung: ${_printerService.connectedDeviceName ?? "Printer"}'
                        : 'Belum terhubung ke printer',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _isConnected
                          ? const Color(0xFF155724)
                          : Colors.grey.shade800,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_isConnected)
                  TextButton(
                    onPressed: _disconnect,
                    child: const Text('Putus', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daftar Perangkat
          const Text(
            'Perangkat Bluetooth Terpasang (Paired):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFF2D5A27)),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kendala Memuat Printer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Coba Lagi'),
                    onPressed: _checkStatusAndLoadDevices,
                  ),
                ],
              ),
            )
          else if (_devices.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak ada printer yang terdeteksi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Nyalakan printer thermal Anda.\n'
                    '2. Buka Bluetooth Pengaturan HP, cari printer dan lakukan Pairing (PIN biasanya: 0000 atau 1234).\n'
                    '3. Tekan tombol segarkan di pojok kanan atas.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _devices.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  final isThisDeviceConnected = _isConnected &&
                      _printerService.connectedMacAddress == device.macAdress;
                  final isConnecting = _connectingMac == device.macAdress;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isThisDeviceConnected
                          ? const Color(0xFFE8F5E9)
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.print,
                        color: isThisDeviceConnected
                            ? const Color(0xFF2D5A27)
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      device.name.isEmpty ? 'Printer Kasir' : device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      device.macAdress,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: isConnecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : (isThisDeviceConnected
                            ? const Chip(
                                label: Text(
                                  'Aktif',
                                  style: TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Color(0xFFD4EDDA),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D5A27),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                onPressed: () => _connectDevice(device),
                                child: const Text(
                                  'Hubungkan',
                                  style: TextStyle(fontSize: 12),
                                ),
                              )),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Tombol Test Print
          if (_isConnected)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D5A27),
                  side: const BorderSide(color: Color(0xFF2D5A27)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Cetak Struk Uji Coba (Test Print)'),
                onPressed: _testPrint,
              ),
            ),
        ],
      ),
    );
  }
}
