import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../core/utils/list_tolse.dart';
import '../../events/controller/event_controller.dart' show EventController;
import '../data/models/client.dart' show Client;
import '../controller/client_controller.dart' show ClientController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/myp_actions.dart' show MyPActions;
import '../../shared/widgets/base_list_screen.dart';

class ClientListScreen extends BaseListScreen<Client, ClientController> {
  const ClientListScreen({super.key});

  @override
  String get title => 'العملاء';

  @override
  String get searchPlaceholder => 'البحث عن عميل...';


  @override
  Widget buildHeader(BuildContext context) => const SizedBox.shrink();

  @override
  List<Client>  getItems(){
    return controller.filteredClients;
  }

  @override
  Widget buildListItem(BuildContext context, Client client) {
    final brightness = Theme.of(context).brightness;
    final String clientAvatar = client.imgUrl ?? '';
    // final lastEvent = controller.getLastEventForClient(client.id);

     final latestEvent = Get.find<EventController>().events
      .where((e) => e.clientId == client.id)
      .sorted((a, b) => b.eventDate.compareTo(a.eventDate)).firstOrNull;

    String recentEventText = 'لا يوجد سجل مناسبات سابقة';
    IconData recentEventIcon = Icons.history_rounded;
    if (latestEvent != null) {
      try {
        recentEventText = 'آخر مناسبة: ${latestEvent.eventName} (${
            DateFormat("d MMMM", "ar")
            .format(DateTime.parse(latestEvent.eventDate))
        })';
        recentEventIcon = Icons.cake_outlined;
      } catch (_) {
        recentEventText = 'آخر مناسبة: ${latestEvent.eventName}';
        recentEventIcon = Icons.event_rounded;
      }
    }


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: client.isDeleted
              ? () => _deleteOrRestoreClient(context, client.id, isDeleted: false)
              : () => Get.toNamed(AppRoutes.clientDetail, arguments: client),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3), width: 2),
                            color: AppColors.background.getByBrightness(brightness),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: _fallbackAvatar(context, clientAvatar),
                          ),
                        ),
                      
                      ],
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name.isNotEmpty ? client.name : 'عميل بدون اسم',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: client.isDeleted
                                  ? AppColors.textSubtitle.getByBrightness(brightness)
                                  : AppColors.textBody.getByBrightness(brightness),
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          Row(
                            children: [
                              Text(
                                client.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSubtitle.getByBrightness(brightness),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: AppColors.primary.getByBrightness(brightness),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                   
                    _buildActionButtons(context, client),
                  ],
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.85,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background.getByBrightness(brightness),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              recentEventText,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSubtitle.getByBrightness(brightness),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            recentEventIcon,
                            size: 16,
                            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _fallbackAvatar(BuildContext context, String clientAvatar) 
  {
    final brightness = Theme.of(context).brightness;
    final ret = Icon(Icons.person_rounded, color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.5), size: 30);
    return clientAvatar.isNotEmpty?
      Image.network(clientAvatar, fit: BoxFit.cover, errorBuilder: (c, e, s) => ret) 
      : ret;
  }
  
  Widget _buildActionButtons(BuildContext context, Client client) 
  {
    final brightness = Theme.of(context).brightness;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: AppColors.textSubtitle.getByBrightness(brightness), size: 20),
      onSelected: (value) => switch(value) {
        'edit' => Get.toNamed(AppRoutes.clientAdd, arguments: client),
        'delete' => _deleteOrRestoreClient(context, client.id, isDeleted: true),
        'restore'=> _deleteOrRestoreClient(context, client.id, isDeleted: false),
        _=> null
      },
      itemBuilder: (context) => client.isDeleted
          ? [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore_from_trash_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('استعادة'),
                  ],
                ),
              ),
            ]
          : [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
    );
  }

  void _deleteOrRestoreClient(BuildContext context, int id, {bool isDeleted = true}) 
  {
    final brightness = Theme.of(context).brightness;
    Get.defaultDialog(
      title: "تأكيد ${isDeleted ? 'الحذف' : 'الاستعادة'}",
      middleText: "هل أنت متأكد من ${isDeleted ? 'حذف' : 'استعادة'} هذا العميل؟",
      backgroundColor: AppColors.surface.getByBrightness(brightness),
      radius: 12,
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: (isDeleted? AppColors.accent : AppColors.primary).getByBrightness(brightness)),
        onPressed: () {
          Get.back();
          isDeleted? controller.deleteClient(id)
          : controller.restoreClient(id);
        },
        child: Text('نعم، ${isDeleted ? 'احذف' : 'استعد'}', style: TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary.getByBrightness(brightness))),
        onPressed: () => Get.back(),
        child: Text('إلغاء', style: TextStyle(color: AppColors.primary.getByBrightness(brightness))),
      ),
    );
  }

   @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return MyPActions.floatButton(
      context,
      icon: Icons.person_add_rounded,
      heroTag: 'add_client',
      onPressed: () => Get.toNamed(AppRoutes.clientAdd),
    );
  }
  
}
