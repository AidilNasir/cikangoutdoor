import 'package:flutter/material.dart';

class TrustBadges extends StatelessWidget {
  const TrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeItem(
        icon: Icons.sanitizer_rounded,
        title: 'Higienis & Wangi',
        subtitle: 'Dicuci berkala',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFFE8F5E9),
      ),
      _BadgeItem(
        icon: Icons.verified_user_rounded,
        title: 'Alat Original',
        subtitle: 'Kokoh & anti bocor',
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
      ),
      _BadgeItem(
        icon: Icons.receipt_long_rounded,
        title: 'Struk Kasir',
        subtitle: 'Print Bluetooth',
        color: const Color(0xFFD35400),
        bgColor: const Color(0xFFFBE9E7),
      ),
      _BadgeItem(
        icon: Icons.bolt_rounded,
        title: 'Proses Instan',
        subtitle: 'Cepat & mudah',
        color: const Color(0xFF6A1B9A),
        bgColor: const Color(0xFFF3E5F5),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: badges.map((badge) {
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: badge.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(badge.icon, size: 18, color: badge.color),
                ),
                const SizedBox(height: 5),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  badge.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BadgeItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;

  _BadgeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
  });
}
