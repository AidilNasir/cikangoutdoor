import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cart_item.dart';
import 'currency_formatter.dart';

class WhatsAppHelper {
  // Nomor WhatsApp Admin Cikang Outdoor (Format internasional tanpa simbol + atau spasi)
  // Contoh: 6281234567890
  static const String adminPhoneNumber = '6282268542286';

  /// Merangkum data keranjang dan data pelanggan menjadi string teks yang rapi dan terstruktur
  static String generateOrderMessage({
    required String customerName,
    required String customerPhone,
    required DateTime rentStartDate,
    required int durationDays,
    required List<CartItem> cartItems,
    required int grandTotal,
  }) {
    final buffer = StringBuffer();
    final formattedDate =
        "${rentStartDate.day.toString().padLeft(2, '0')}/${rentStartDate.month.toString().padLeft(2, '0')}/${rentStartDate.year}";

    buffer.writeln("🌲 *FORMULIR SEWA CIKANG OUTDOOR* 🌲");
    buffer.writeln("=================================");
    buffer.writeln("👤 *Nama Penyewa:* $customerName");
    buffer.writeln("📱 *No. WhatsApp:* $customerPhone");
    buffer.writeln("📅 *Tgl Pengambilan:* $formattedDate");
    buffer.writeln("⏳ *Durasi Sewa:* $durationDays Hari");
    buffer.writeln("---------------------------------");
    buffer.writeln("📦 *RINCIAN ALAT YANG DISEWA:*");

    for (var i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      final itemTotal = item.subtotal * durationDays;
      buffer.writeln(
        "${i + 1}. *${item.gear.name}*\n"
        "   • Jumlah: ${item.quantity} unit\n"
        "   • Tarif: ${CurrencyFormatter.format(item.gear.pricePerDay)}/hari\n"
        "   • Subtotal: ${CurrencyFormatter.format(itemTotal)}",
      );
    }

    buffer.writeln("---------------------------------");
    buffer.writeln(
      "💰 *TOTAL BIAYA SEWA:* ${CurrencyFormatter.format(grandTotal)}",
    );
    buffer.writeln("=================================");
    buffer.writeln(
      "Halo Admin Cikang Outdoor, saya ingin mengonfirmasi ketersediaan alat-alat di atas untuk tanggal tersebut. Mohon informasinya. Terima kasih! 🙏",
    );

    return buffer.toString();
  }

  /// Membuka WhatsApp secara langsung menggunakan url_launcher
  /// Dilengkapi penanganan canLaunchUrl dan fallback jika aplikasi belum terpasang
  static Future<void> sendOrderToWhatsApp({
    required BuildContext context,
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/$adminPhoneNumber?text=$encodedMessage';
    final uri = Uri.parse(urlString);

    try {
      final canOpen = await canLaunchUrl(uri);
      if (canOpen) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          _showFallbackDialog(context, message);
        }
      } else {
        if (!context.mounted) return;
        _showFallbackDialog(context, message);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showFallbackDialog(context, message);
    }
  }

  static void _showFallbackDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('WhatsApp Tidak Terbuka'),
          ],
        ),
        content: const Text(
          'Tidak dapat membuka aplikasi WhatsApp secara otomatis. '
          'Pastikan WhatsApp terinstal di perangkat Anda, atau salin rekap pesanan ini secara manual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5A27),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Salin Pesanan'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesan berhasil disalin ke clipboard!'),
                  backgroundColor: Color(0xFF2D5A27),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
