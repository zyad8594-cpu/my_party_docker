import 'package:flutter/material.dart';
  
import 'package:get/get.dart';
import '../../../../core/components/widgets/search_box_widget.dart' show SearchBox;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../clients/data/models/client.dart' show Client;
import '../../controller/event_controller.dart' show EventController;
import '../../../clients/controller/client_controller.dart' show ClientController;
import '../../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../../../core/components/app_image.dart';
import '../../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;

class EventClientSelectionScreen extends StatelessWidget {
  EventClientSelectionScreen({super.key});

  final EventController controller = Get.find<EventController>();
  final ClientController clientController = Get.find<ClientController>();

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    // final event = Get.arguments;
    // final Client? client = Get.arguments;
    if(Get.arguments != null)
    {
      controller.clientIdRx.value = Get.arguments;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (clientController.clients.isEmpty) {
        clientController.fetchAll();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: AppBar(
        title: const Text('إضافة مناسبة جديدة'),
        backgroundColor: AppColors.card.getByBrightness(brightness),
        elevation: 0,
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_rounded, color: AppColors.textBody.getByBrightness(brightness)),
        //   onPressed: (){
        //     Get.back(result: client);
        //   },
        // ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.clientAdd),
            icon: Icon(Icons.add_rounded, color: AppColors.textBody.getByBrightness(brightness)),
            label: Text(
              'إضافة عميل',
              style: TextStyle(
                color: AppColors.textBody.getByBrightness(brightness),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],

        bottom: PreferredSize(preferredSize: Size(Get.size.width, 10), child: const Text('اختيار العميل')),
      ),
      body: Column(
        children: [
          // TextField(
          //   onChanged: (value) => clientController.searchQuery.value = value,
          //   decoration: AppFormWidgets.searchDecoration('البحث عن عميل...', context),
          // ),
          // const SizedBox(height: 16),
      
          Expanded(
            child: 
            // Obx(() {
              // if (clientController.isLoading.value) {
              //   return const LoadingWidget();
              // }
              // if (clientController.filteredClients.isEmpty) {
              //   return Center(
              //     child: Text(
              //       'لا يوجد عملاء. أضف عميلاً جديداً.',
              //       style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
              //     ),
              //   );
              // }
      
              // return 
              MyPListView.builder<Client>(
                context,
                onRefresh: () => clientController.fetchAll(force: true),
                isLoading: clientController.isLoading,
                padding: const EdgeInsets.all(24),
                loadingWidget: () => const LoadingWidget(),
                emptyWidget: () {
                  return Center(
                  child: Text(
                    'لا يوجد عملاء. أضف عميلاً جديداً.',
                    style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
                  ),
                );
                },
                filters: () => clientController.filteredClients,
                scrollController: clientController.scrollController,
                header: SearchBox.withNotLayout(
                  context, 'searchText',
                  searchOnChanged: (value) => clientController.searchQuery.value = value,
                  decoration: AppFormWidgets.searchDecoration('البحث عن عميل...', context)
                ),
                itemBuilder: (context, index, client) {
                  return Obx(() {
                    final isSelected =
                        controller.clientIdRx.value == client.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)
                            : AppColors.card.getByBrightness(brightness),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.getByBrightness(brightness)
                              : AppColors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        // onTap: () => controller.clientIdRx.value = client.id,
                        onTap: () => Get.back(result: client),
                        leading: ClipOval(
                          child: AppImage.network(
                            client.imgUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            viewerTitle: client.name,
                            fallbackWidget: Container(
                              width: 40,
                              height: 40,
                              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.primary.getByBrightness(brightness),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          client.name.isNotEmpty ? client.name : 'بدون اسم',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client.phoneNumber, style: const TextStyle(fontSize: 13)),
                            if (client.email != null && client.email!.isNotEmpty)
                              Text(client.email!, style: TextStyle(fontSize: 12, color: AppColors.grey[600])),
                          ],
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary.getByBrightness(brightness),
                              )
                            : null,
                      ),
                    );
                  });
                },
              )
            // }),
          ),
          // const SizedBox(height: 16),
      
          // Obx(
          //   () => Padding(
          //     // width: double.infinity,
          //     // height: 55,
          //     padding: const EdgeInsets.all(24),
          //     child: Container(
          //       width: double.infinity,
          //       height: 55,
          //       decoration: BoxDecoration(
          //         gradient: controller.clientIdRx.value != 0
          //             ? AppColors.primaryGradient.getByBrightness(brightness)
          //             : LinearGradient(
          //                 colors: [AppColors.grey[400]!, AppColors.grey[400]!],
          //               ),
          //         borderRadius: BorderRadius.circular(20),
          //         boxShadow: controller.clientIdRx.value != 0 ? [
          //           BoxShadow(
          //             color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
          //             blurRadius: 12,
          //             offset: const Offset(0, 4),
          //           ),
          //         ] : null,
          //       ),
          //       child: ElevatedButton(
          //         onPressed: controller.clientIdRx.value != 0
          //             ? () {
                          
                          
          //                 // controller.eventNameRx.value = event['nameEvent'];
          //                 // controller.dateRx.value = event['dateEvent'];
          //                 // controller.locationRx.value = event['location'];
          //                 // controller.descriptionRx.value = event['description'];
          //                 // controller.budgetRx.value = event['budget'];
      
          //                 // controller.create();
          //                 // controller.fetchEvents();
          //                 Get.back(result: controller.clientIdRx.value);
          //               }
          //             : null,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: AppColors.transparent,
          //           shadowColor: AppColors.transparent,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(16),
          //           ),
          //         ),
          //         child: controller.isLoading.value
          //             ? const LoadingWidget(color: AppColors.white, size: 20)
          //             : const Text(
          //                 'إنشاء المناسبة',
          //                 style: TextStyle(
          //                   color: AppColors.white,
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16,
          //                 ),
          //               ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
