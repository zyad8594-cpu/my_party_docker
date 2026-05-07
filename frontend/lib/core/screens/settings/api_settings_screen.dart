import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/config_service.dart';
import '../../themes/app_colors.dart';
import '../../components/gradient_button.dart';
import '../../components/glass_card.dart';
// import 'package:my_party/core/themes/app_colors.dart';


class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final ConfigService _config = Get.find<ConfigService>();
  final TextEditingController _urlController = TextEditingController();
  final RxString _previewUrl = ''.obs;

  @override
  void initState() {
    super.initState();
    _urlController.text = _config.baseUrl.value;
    _previewUrl.value = _config.baseUrl.value;
    
    _urlController.addListener(() {
      _previewUrl.value = _urlController.text;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رابط صالح', 
          backgroundColor: AppColors.red.withValues(alpha: 0.1),
          colorText: AppColors.red);
      return;
    }

    await _config.updateBaseUrl(newUrl);
    
    Get.snackbar('تم الحفظ', 'تم تحديث رابط الـ API بنجاح',
        backgroundColor: AppColors.green.withValues(alpha: 0.1),
        colorText: AppColors.green);
        
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }

  // Removed unused _resetToDefault method

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: AppBar(
        title: const Text('إعدادات الرابط (API)'),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.settings_remote_rounded, size: 80, color: AppColors.primary.getByBrightness(brightness)),
            const SizedBox(height: 24),
            Text(
              'تغيير رابط الـ API',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody.getByBrightness(brightness),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'هذه الصفحة مخصصة للمطورين لتغيير بيئة العمل',
              style: TextStyle(
                color: AppColors.textSubtitle.getByBrightness(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الرابط الحالي:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBody.getByBrightness(brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.getByBrightness(brightness).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      _previewUrl.value,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  )),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'الرابط الجديد',
                      hintText: 'http://192.168.1.x:3000/api',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    text: 'حفظ وإعادة ضبط',
                    onPressed: _saveSettings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Presets
            Text(
              'روابط مقترحة:',
              style: TextStyle(
                color: AppColors.textSubtitle.getByBrightness(brightness),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildPresetCard('Local Machine', 'http://10.0.2.2:3000/api'),
            _buildPresetCard('PC (Home WiFi)', 'http://192.168.1.5:3000/api'),
            _buildPresetCard('Mobile Hotspot', 'http://192.168.43.39:3000/api'),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(String title, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(url, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _urlController.text = url,
      ),
    );
  }
}
