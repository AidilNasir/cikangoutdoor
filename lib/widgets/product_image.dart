import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  Widget _buildFallback() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFE8F5E9),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.landscape_rounded,
                  size: 38,
                  color: Color(0xFF2D5A27),
                ),
                SizedBox(height: 4),
                Text(
                  'Cikang Outdoor',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2D5A27),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
  }

  // Cache memori untuk base64 image agar tidak membebani CPU / menyebabkan UI lag
  static final Map<int, Uint8List> _base64Cache = {};

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      return _buildFallback();
    }

    Widget content;

    // 1. Data URI / Base64 image
    if (trimmed.startsWith('data:image') ||
        (trimmed.length > 200 && !trimmed.startsWith('http') && !trimmed.startsWith('/'))) {
      try {
        final hash = trimmed.hashCode;
        Uint8List? bytes = _base64Cache[hash];

        if (bytes == null) {
          final commaIndex = trimmed.indexOf(',');
          final base64Str = commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
          bytes = base64Decode(base64Str.trim());
          // Simpan ke cache agar decode berikutnya 0 ms, batasi 20 item untuk hemat RAM
          if (_base64Cache.length > 20) {
            _base64Cache.remove(_base64Cache.keys.first);
          }
          _base64Cache[hash] = bytes;
        }

        content = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: 350,
          cacheHeight: 350,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (e) {
        content = _buildFallback();
      }
    }
    // 2. Local File Image (Non-Web)
    else if (!kIsWeb &&
        (trimmed.startsWith('/') ||
            trimmed.startsWith('file:') ||
            (trimmed.length > 2 && trimmed[1] == ':'))) {
      try {
        final filePath = trimmed.replaceFirst('file://', '');
        final file = File(filePath);
        if (file.existsSync()) {
          content = Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        } else {
          content = _buildFallback();
        }
      } catch (e) {
        content = _buildFallback();
      }
    }
    // 3. Asset image
    else if (trimmed.startsWith('assets/')) {
      content = Image.asset(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    // 4. Web URL dari Google / Unsplash
    else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      content = Image.network(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: 400,
        cacheHeight: 400,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: const Color(0xFFF1F5F0),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2D5A27),
                    ),
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      content = _buildFallback();
    }

    // Wrap in a colored Container to ensure no black canvas ever shows
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F0),
      child: content,
    );
  }
}
