import 'dart:io' show Platform;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/transaction_item.dart';
import '../utils/currency_formatter.dart';
import '../utils/whatsapp_helper.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  String? connectedMacAddress;
  String? connectedDeviceName;

  /// Memeriksa apakah platform saat ini didukung oleh plugin (Android & iOS)
  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Meminta izin Bluetooth yang diperlukan (terutama Android 12+ / API 31+)
  Future<bool> requestPermissions() async {
    if (!isSupportedPlatform) return true;
    try {
      if (Platform.isAndroid) {
        final statuses = await [
          Permission.bluetooth,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.location,
        ].request();

        final connectGranted =
            statuses[Permission.bluetoothConnect]?.isGranted ?? true;
        final scanGranted =
            statuses[Permission.bluetoothScan]?.isGranted ?? true;

        return connectGranted && scanGranted;
      }
    } catch (e) {
      debugPrint('Error requesting bluetooth permissions: $e');
    }
    return true;
  }

  /// Memeriksa apakah izin Bluetooth sudah diberikan
  Future<bool> hasBluetoothPermission() async {
    if (!isSupportedPlatform) return true;
    try {
      if (Platform.isAndroid) {
        final isConnectGranted = await Permission.bluetoothConnect.isGranted;
        if (!isConnectGranted) {
          // Cek juga melalui method bawaan plugin jika tersedia
          try {
            return await PrintBluetoothThermal.isPermissionBluetoothGranted;
          } catch (_) {
            return false;
          }
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error checking bluetooth permission: $e');
    }
    return true;
  }

  /// Memeriksa apakah bluetooth aktif
  Future<bool> isBluetoothEnabled() async {
    if (!isSupportedPlatform) return false;
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint('Error checking if bluetooth is enabled: $e');
      return false;
    }
  }

  /// Memeriksa status koneksi printer
  Future<bool> isConnected() async {
    if (!isSupportedPlatform) return false;
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      debugPrint('Error checking connection status: $e');
      return false;
    }
  }

  /// Mendapatkan daftar perangkat Bluetooth yang sudah dipasangkan (paired)
  Future<List<BluetoothInfo>> getPairedPrinters() async {
    if (!isSupportedPlatform) {
      // Mock / dummy printer untuk pengujian UI di desktop / web
      return [
        BluetoothInfo(
          name: 'Printer Thermal 58mm (Mode Simulasi)',
          macAdress: '00:11:22:33:44:55',
        ),
      ];
    }

    try {
      // Pastikan izin telah diminta sebelum mengambil daftar perangkat
      await requestPermissions();
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      debugPrint('Error getting paired printers: $e');
      return [];
    }
  }

  /// Menghubungkan ke printer bluetooth berdasarkan mac address
  Future<bool> connect(BluetoothInfo device) async {
    if (!isSupportedPlatform) {
      connectedMacAddress = device.macAdress;
      connectedDeviceName = device.name;
      return true;
    }

    try {
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );
      if (connected) {
        connectedMacAddress = device.macAdress;
        connectedDeviceName = device.name;
      }
      return connected;
    } catch (e) {
      debugPrint('Error connecting to printer: $e');
      return false;
    }
  }

  /// Memutus koneksi printer
  Future<bool> disconnect() async {
    if (!isSupportedPlatform) {
      connectedMacAddress = null;
      connectedDeviceName = null;
      return true;
    }

    try {
      final status = await PrintBluetoothThermal.disconnect;
      connectedMacAddress = null;
      connectedDeviceName = null;
      return status;
    } catch (e) {
      debugPrint('Error disconnecting printer: $e');
      connectedMacAddress = null;
      connectedDeviceName = null;
      return false;
    }
  }

  /// Mencetak struk bukti sewa Cikang Outdoor
  Future<bool> printRentalReceipt(TransactionItem tx) async {
    if (!isSupportedPlatform) {
      debugPrint('Simulasi cetak struk: ${tx.id} berhasil di platform non-mobile');
      return true;
    }

    final connected = await isConnected();
    if (!connected) return false;

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Header Toko
      bytes += generator.text(
        'CIKANG OUTDOOR',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      bytes += generator.text(
        'Rental Alat Camping & Outdoor',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Kendari - Sulawesi Tenggara',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'WA: +${WhatsAppHelper.adminPhoneNumber}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Info Transaksi
      final dateStr =
          "${tx.rentStartDate.day.toString().padLeft(2, '0')}/${tx.rentStartDate.month.toString().padLeft(2, '0')}/${tx.rentStartDate.year}";
      bytes += generator.text('Tgl Sewa : $dateStr');
      bytes += generator.text('Penyewa  : ${tx.customerName}');
      if (tx.customerPhone.isNotEmpty) {
        bytes += generator.text('No. HP   : ${tx.customerPhone}');
      }
      bytes += generator.text('Durasi   : ${tx.durationDays} Hari');
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Rincian Alat
      bytes += generator.text(
        'RINCIAN SEWA:',
        styles: const PosStyles(bold: true),
      );
      bytes += generator.text(tx.itemsSummary);
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Total & Status
      bytes += generator.text(
        'TOTAL BIAYA: ${CurrencyFormatter.format(tx.totalAmount)}',
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      bytes += generator.text('Status     : ${tx.status.toUpperCase()}');
      bytes += generator.text(
        '================================',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Ketentuan Sewa
      bytes += generator.text(
        '* Wajib KTP/SIM Asli saat ambil',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        '* Harap jaga kebersihan alat',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Terima Kasih & Salam Lestari!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Error printing rental receipt: $e');
      return false;
    }
  }

  /// Mencetak uji coba struk (Test Print)
  Future<bool> printTestReceipt() async {
    if (!isSupportedPlatform) {
      debugPrint('Simulasi test print berhasil di platform non-mobile');
      return true;
    }

    final connected = await isConnected();
    if (!connected) return false;

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      bytes += generator.text(
        'CIKANG OUTDOOR',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      bytes += generator.text(
        'UJI COBA PRINTER BERHASIL',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'Printer Thermal Siap Digunakan!',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Error printing test receipt: $e');
      return false;
    }
  }
}
