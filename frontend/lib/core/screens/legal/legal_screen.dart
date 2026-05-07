import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/app_colors.dart';
import '../../components/glass_card.dart';
// import 'package:my_party/core/themes/app_colors.dart';


class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.appBarBackground.getByBrightness(brightness),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: TextStyle(
                  color: AppColors.textBody.getByBrightness(brightness),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient.getByBrightness(brightness).colors
                        .map((c) => c.withValues(alpha: 0.1))
                        .toList(),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: AppColors.textBody.getByBrightness(brightness),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'آخر تحديث: أبريل 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
