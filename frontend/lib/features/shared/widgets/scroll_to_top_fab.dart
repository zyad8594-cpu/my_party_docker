import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart' show AppColors;
class ScrollToTopFab extends StatelessWidget {
  final RxBool showScrollToTop;
  final VoidCallback onPressed;
  const ScrollToTopFab({
    super.key,
    required this.showScrollToTop,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Obx(() {
      if (!showScrollToTop.value) return const SizedBox.shrink();
      return FloatingActionButton(
        heroTag: null,
        onPressed: onPressed,
        backgroundColor: AppColors.primary.getByBrightness(brightness),
        mini: true,
        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
      );
    });
  }
}
