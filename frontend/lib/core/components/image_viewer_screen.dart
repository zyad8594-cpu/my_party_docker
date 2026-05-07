import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../themes/app_colors.dart';


class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _isDownloading = false;

  bool get isDownloading => _isDownloading;
  set isDownloading(bool value) => setState(() => _isDownloading = value);

  Future<void> _shareImage() async {
    try {
      isDownloading = true;
      
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/shared_image.jpg';
      
      await Dio().download(widget.imageUrl, path);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)], 
        text: widget.title ?? 'مشاركة الصورة'
      ));
      // await Share.shareXFiles([XFile(path)], text: widget.title ?? 'مشاركة الصورة');
    } 
    catch (e) 
    {
      Get.snackbar('خطأ', 'فشل في مشاركة الصورة: $e', 
          backgroundColor: AppColors.red, colorText: AppColors.white);
    } 
    finally 
    {
      isDownloading = false;
    }
  }

  Future<void> _downloadImage() async {
    try 
    {
      isDownloading = true;
      
      Directory? downloadsDir = Platform.isAndroid? 
        Directory('/storage/emulated/0/Download') :
        await getApplicationDocumentsDirectory();

      final fileName = 'MyParty_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${downloadsDir.path}/$fileName';
      
      await Dio().download(widget.imageUrl, path);
      
      Get.snackbar('تم التنزيل', 'تم حفظ الصورة في المجلد: ${downloadsDir.path}', 
          backgroundColor: AppColors.green, colorText: AppColors.white);
    } 
    catch (e) 
    {
      /// اللجوء إلى المشاركة في حال فشل التنزيل المباشر بسبب مشاكل في الأذونات
      await _shareImage();
    } 
    finally 
    {
      isDownloading = false;
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title ?? 'عرض الصورة',
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        ),
        actions: [
          if (isDownloading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.white),
              onPressed: _shareImage,
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: AppColors.white),
              onPressed: _downloadImage,
            ),
          ]
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: widget.imageUrl,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.white,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image_rounded, color: AppColors.white, size: 64),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
