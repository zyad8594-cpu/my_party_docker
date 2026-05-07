import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'image_viewer_screen.dart';
import '../themes/app_colors.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class AppImage {
  static ImageProvider? provider(String? url) {
    if (url == null || url.trim().isEmpty || !url.startsWith('http')) {
      return null;
    }
    return CachedNetworkImageProvider(url);
  }

  static Future<void> clearCache(String url) async {
    try {
      await DefaultCacheManager().removeFile(url);
      PaintingBinding.instance.imageCache.evict(CachedNetworkImageProvider(url));
      debugPrint('🗑️ Cleared cache for: $url');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  static Widget getAvatarFallback({required Brightness brightness, IconData icon = Icons.person, double size = 28}) {
    return Icon(icon, color: brightness == Brightness.dark ? AppColors.white54 : AppColors.black54, size: size);
  }

  static Widget network(
    String? url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
    Color? fallbackColor,
    IconData fallbackIcon = Icons.image_not_supported_rounded,
    double fallbackIconSize = 24.0,
    bool isClickable = true,
    String? viewerTitle,
    Key? key,
  }) {
    if (url == null || url.trim().isEmpty || !url.startsWith('http')) {
      return _buildFallback(width, height, fallbackColor, fallbackWidget, fallbackIcon, fallbackIconSize);
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: url,
      key: key,
      cacheKey: url, // Use the URL itself as the cache key
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildFallback(width, height, fallbackColor, fallbackWidget, fallbackIcon, fallbackIconSize),
      errorWidget: (context, url, error) => _buildFallback(width, height, fallbackColor, fallbackWidget, fallbackIcon, fallbackIconSize),
    );

    if (!isClickable) return imageWidget;

    return GestureDetector(
      onTap: () => Get.to(() => ImageViewerScreen(
        imageUrl: url,
        title: viewerTitle ?? 'عرض الصورة',
      )),
      child: imageWidget,
    );
  }

  static Widget _buildFallback(double? w, double? h, Color? color, Widget? widget, IconData icon, double iconSize) {
    if (widget != null) return widget;
    return Container(
      width: w,
      height: h,
      color: color ?? AppColors.grey.withValues(alpha: 0.1),
      child: Center(
        child: Icon(icon, color: AppColors.grey.withValues(alpha: 0.5), size: iconSize),
      ),
    );
  }
}
