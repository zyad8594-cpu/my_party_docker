import 'package:flutter/material.dart';
  
import 'package:get/get.dart';
import '../../../../core/api/auth_service.dart';
import '../data/models/coordinator.dart' show Coordinator;
import '../controller/coordinator_controller.dart' show CoordinatorController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/app_image.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../core/utils/utils.dart' show MyPUtils;

class CoordinatorDetailScreen extends GetView<CoordinatorController> {
  const CoordinatorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dynamic args = Get.arguments;
    
    Coordinator coordinatorArg;
    if (args is Map) {
      coordinatorArg = Coordinator(
        id: args['id'],
        name: args['name'] ?? '',
        email: args['email'] ?? '',
        password: '',
        isActive: args['is_active'] ?? false,
      );
      // Trigger a fetch if we want more details (like phone number)
      // controller.getById(coordinatorArg.id); 
    } else {
      coordinatorArg = args;
    }
    
    // Use Obx to listen to changes in the controller's coordinators list or selected coordinator
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true, 
        title: coordinatorArg.name
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.background.getByBrightness(brightness)),
        child: Obx(() {
          // Find the latest version of this coordinator in the controller list
          final coordinator = controller.coordinators.firstWhere(
            (c) => c.id == coordinatorArg.id, 
            orElse: () => coordinatorArg
          );
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(coordinator, context),
                const SizedBox(height: 32),
                _buildInfoSection(coordinator, context),
                const SizedBox(height: 40),
                _buildActions(context, coordinator),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(Coordinator coordinator, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.getByBrightness(brightness),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: coordinator.imgUrl != null
                    ? ClipOval(
                        child: AppImage.network(
                          coordinator.imgUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          viewerTitle: coordinator.name,
                          fallbackWidget: Text(
                            coordinator.name.isNotEmpty ? coordinator.name.substring(0, 1).toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.w_b.getByBrightness(brightness),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        coordinator.name.isNotEmpty ? coordinator.name.substring(0, 1).toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.w_b.getByBrightness(brightness),
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: coordinator.isActive ? AppColors.green : AppColors.red,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surface.getByBrightness(brightness), width: 2),
                ),
                child: Text(
                  coordinator.isActive ? 'نشط' : 'معطل',
                  style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          coordinator.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
        Text(
          'منسق حفلات معتمد',
          style: TextStyle(color: AppColors.primary.getByBrightness(brightness), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Coordinator coordinator, BuildContext context) 
  {
    return Column(
      children: [
        _buildInfoCard(
          Icons.email_outlined,
          'البريد الإلكتروني',
          coordinator.email,
          context,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          Icons.phone_outlined,
          'رقم الهاتف',
          coordinator.phoneNumber ?? 'لا يوجد',
          context,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          Icons.calendar_today_outlined,
          'تاريخ الانضمام',
          'مارس 2024',
          context,
        ), // Mocked date
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary.getByBrightness(brightness)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSubtitle.getByBrightness(brightness),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textBody.getByBrightness(brightness),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Coordinator coordinator) 
  {
    final brightness = Theme.of(context).brightness;
    final isAdmin = AuthService.userIsAdmin;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(
                  '/coordinators/add',
                  arguments: coordinator,
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('تعديل البيانات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface.getByBrightness(brightness),
                  foregroundColor: AppColors.primary.getByBrightness(brightness),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: ElevatedButton.icon(
            //     onPressed: () async {
            //       if (coordinator.phoneNumber != null) {
            //         final Uri whatsappUri = Uri.parse("https://wa.me/${coordinator.phoneNumber}");
            //         if (await canLaunchUrl(whatsappUri)) {
            //           await launchUrl(whatsappUri);
            //         } else {
            //           MyPUtils.showSnackbar('خطأ', 'لا يمكن فتح الواتساب');
            //         }
            //       } else {
            //         MyPUtils.showSnackbar('تنبيه', 'رقم الهاتف غير متوفر');
            //       }
            //     },
            //     icon: const Icon(Icons.message_outlined, size: 18),
            //     label: const Text('مراسلة المنسق'),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary.getByBrightness(brightness),
            //       foregroundColor: AppColors.white,
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //     ),
            //   ),
            // ),
          ],
        ),
        if (isAdmin) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.toggleStatus(coordinator.id, !coordinator.isActive),
                  icon: Icon(
                    coordinator.isActive ? Icons.block_flipped : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(coordinator.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coordinator.isActive ? AppColors.red.withValues(alpha: 0.1) : AppColors.green.withValues(alpha: 0.1),
                    foregroundColor: coordinator.isActive ? AppColors.red : AppColors.green,
                    elevation: 0,
                    side: BorderSide(color: coordinator.isActive ? AppColors.red : AppColors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: ElevatedButton.icon(
              //     onPressed: () => _delete(coordinator.id, context),
              //     icon: const Icon(Icons.delete_rounded, size: 18),
              //     label: const Text('حذف الحساب'),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.1),
              //       foregroundColor: AppColors.accent.getByBrightness(brightness),
              //       elevation: 0,
              //       padding: const EdgeInsets.symmetric(vertical: 12),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ],
    );
  }

  // void _delete(int id, BuildContext context) {
  //   MyPUtils.showConfirmDialog(
  //     context: context,
  //     title: 'حذف المنسق',
  //     message: 'هل أنت متأكد من حذف هذا المنسق نهائياً؟',
  //     confirmLabel: 'حذف',
  //     isDanger: true,
  //     onConfirm: () {
  //       controller.delete(id);
  //       Get.back(); // Return to list
  //     },
  //   );
  // }
}
