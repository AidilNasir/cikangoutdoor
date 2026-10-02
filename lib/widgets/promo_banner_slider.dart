import 'dart:async';
import 'package:flutter/material.dart';

class PromoBannerItem {
  final String title;
  final String subtitle;
  final String tag;
  final IconData tagIcon;
  final String ctaText;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData backgroundIcon;
  final String? targetCategory;

  const PromoBannerItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagIcon,
    required this.ctaText,
    required this.gradientColors,
    required this.accentColor,
    required this.backgroundIcon,
    this.targetCategory,
  });
}

class PromoBannerSlider extends StatefulWidget {
  final Function(String category)? onCategorySelected;
  final VoidCallback? onPrinterPressed;

  const PromoBannerSlider({
    super.key,
    this.onCategorySelected,
    this.onPrinterPressed,
  });

  @override
  State<PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends State<PromoBannerSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _timer;

  final List<PromoBannerItem> _banners = const [
    PromoBannerItem(
      title: 'Diskon Weekend Camp! 🏕️',
      subtitle: 'Sewa 3 hari bayar 2 hari khusus Tenda Dome & Matras.',
      tag: 'PROMO SPESIAL',
      tagIcon: Icons.local_fire_department,
      ctaText: 'Lihat Tenda',
      gradientColors: [Color(0xFF0F3818), Color(0xFF1B5E20), Color(0xFF2D5A27)],
      accentColor: Color(0xFFFFD54F),
      backgroundIcon: Icons.holiday_village_rounded,
      targetCategory: 'Tenda',
    ),
    PromoBannerItem(
      title: 'Paket Jelajah Gunung 🏔️',
      subtitle: 'Siap summit Mekongga & Anoa dengan Carrier & Tenda kokoh.',
      tag: 'TERLARIS',
      tagIcon: Icons.trending_up,
      ctaText: 'Cek Carrier',
      gradientColors: [Color(0xFF2C1654), Color(0xFF78281F), Color(0xFFD35400)],
      accentColor: Color(0xFFFF9E80),
      backgroundIcon: Icons.hiking_rounded,
      targetCategory: 'Tas Carrier',
    ),
    PromoBannerItem(
      title: 'Alat Bersih & Higienis ✨',
      subtitle: 'Semua tenda & sleeping bag dicuci wangi, pasak & frame lengkap.',
      tag: 'KUALITAS PRIMA',
      tagIcon: Icons.verified_rounded,
      ctaText: 'Lihat Semua',
      gradientColors: [Color(0xFF0A2E36), Color(0xFF0E4D5A), Color(0xFF1B6A78)],
      accentColor: Color(0xFF80DEEA),
      backgroundIcon: Icons.clean_hands_rounded,
      targetCategory: 'Semua',
    ),
    PromoBannerItem(
      title: 'Kasir Struk Bluetooth 🧾',
      subtitle: 'Sewa kini didukung cetak struk kasir thermal resmi & instan.',
      tag: 'FITUR RESMI',
      tagIcon: Icons.print_rounded,
      ctaText: 'Kelola Printer',
      gradientColors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
      accentColor: Color(0xFF4DD0E1),
      backgroundIcon: Icons.receipt_long_rounded,
      targetCategory: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleBannerTap(PromoBannerItem item) {
    if (item.targetCategory != null && widget.onCategorySelected != null) {
      widget.onCategorySelected!(item.targetCategory!);
    } else if (item.ctaText == 'Kelola Printer' && widget.onPrinterPressed != null) {
      widget.onPrinterPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.96,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => _handleBannerTap(banner),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: banner.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: banner.gradientColors.last.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background decorative icon watermark
                        Positioned(
                          right: -12,
                          bottom: -16,
                          child: Icon(
                            banner.backgroundIcon,
                            size: 110,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        // Ambient glowing circle
                        Positioned(
                          top: -20,
                          right: 40,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: banner.accentColor.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        // Content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Tag Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: banner.accentColor.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    banner.tagIcon,
                                    size: 13,
                                    color: banner.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    banner.tag,
                                    style: TextStyle(
                                      color: banner.accentColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Title & Subtitle
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  banner.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                            // Action CTA Pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        banner.ctaText,
                                        style: TextStyle(
                                          color: banner.gradientColors.first,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13,
                                        color: banner.gradientColors.first,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 20 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2D5A27)
                    : const Color(0xFF2D5A27).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
