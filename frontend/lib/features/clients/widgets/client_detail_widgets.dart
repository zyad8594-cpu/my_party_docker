import 'package:intl/intl.dart' show DateFormat;
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import '../../../core/components/app_image.dart';
import '../../events/controller/event_controller.dart';
  


import '../data/models/client.dart' show Client;
import '../../events/data/models/event.dart' show Event;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/routes/app_routes.dart' show AppRoutes;

class ClientDetailWidgets 
{
  static Widget buildActionIcon(IconData icon, Color color, VoidCallback onTap,) 
  {
    return InkWell
    (
      onTap: onTap,
      child: Container
      (
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration
        (
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  static Widget contactTile(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
    BuildContext context,
  ) 
  {
    final brightness = Theme.of(context).brightness;

    return InkWell
    (
      onTap: onTap,
      child: Row
      (
        children: <Widget>
        [
          Container
          (
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration
            (
              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary.getByBrightness(brightness), size: 20),
          ),
          const SizedBox(width: 16),

          Expanded
          (
            child: Column
            (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>
              [
                Text
                (
                  label,
                  style: TextStyle
                  (
                    color: AppColors.textSubtitle.getByBrightness(brightness),
                    fontSize: 12,
                  ),
                ),
                
                Text
                (
                  value,
                  style: TextStyle
                  (
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody.getByBrightness(brightness),
                  ),
                ),
              
              ],
            ),
          ),
          
          Icon
          (
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.w_b.getByBrightness(brightness),
          ),
        
        ],
      ),
    );
  }

}

class ClientDetailHeader extends StatelessWidget 
{
  final Client client;

  const ClientDetailHeader({super.key, required this.client});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return Column
    (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>
      [
        Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>
          [
            Expanded
            (
              child: Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>
                [
                  Text
                  (
                    client.name,
                    style: TextStyle
                    (
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBody.getByBrightness(brightness),
                    ),
                  ),
                  
                  Text
                  (
                    'عميل منذ: ${DateFormat('yyyy/MM/dd').format(DateTime.parse(client.createdAt))}',
                    style: TextStyle
                    (
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                      fontSize: 14,
                    ),
                  ),
                
                ],
              ),
            ),
            
            ClientDetailWidgets.buildActionIcon
            (
              Icons.edit_rounded,
              AppColors.primary.getByBrightness(brightness),
              ()=> Get.toNamed(AppRoutes.clientAdd, arguments: client),
            ),
          
          ],
        ),
      ],
    );
  }
}

class ClientContactSection extends StatelessWidget 
{
  final Client client;

  const ClientContactSection({super.key, required this.client});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return Container
    (
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration
      (
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
        boxShadow: <BoxShadow>
        [
          BoxShadow
          (
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column
      (
        children: <Widget>
        [
          ClientDetailWidgets.contactTile
          (
            Icons.phone_rounded,
            'الجوال',
            client.phoneNumber,
            () {},
            context,
          ),
          const Divider(height: 30),

          ClientDetailWidgets.contactTile
          (
            Icons.email_rounded,
            'البريد الإلكتروني',
            client.email ?? 'غير متوفر',
            () {},
            context,
          ),
          const Divider(height: 30),

          ClientDetailWidgets.contactTile
          (
            Icons.location_on_rounded,
            'العنوان',
            client.address ?? 'غير محدد',
            () {},
            context,
          ),
        
        ],
      ),
    );
  }
}

class ClientEventsList extends StatelessWidget 
{
  final Client client;

  const ClientEventsList({super.key, required this.client});

  @override
  Widget build(BuildContext context) 
  {
    final eventController = Get.find<EventController>();
    
    return Obx
    (
      () 
      {
       
        final events = eventController.events.where((e)=> 
          e.clientId == client.id
          
        ).toList();
        if (events.isEmpty) return const ClientEmptyEvents();

        return ListView.builder
        (
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) 
          {
            final event = events[index];
            return ClientEventCard(event: event);
          },
        );
      }
    );
  }
}

class ClientEventCard extends StatelessWidget 
{
  final Event event;

  const ClientEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return Container
    (
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration
      (
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
        boxShadow: <BoxShadow>
        [
          BoxShadow
          (
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material
      (
        color: AppColors.transparent,
        child: InkWell
        (
          onTap: () => Get.toNamed(AppRoutes.eventDetail, arguments: event),
          borderRadius: BorderRadius.circular(24),
          child: Padding
          (
            padding: const EdgeInsets.all(16),
            child: Row
            (
              children: <Widget>
              [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage.network(
                    event.imgUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    viewerTitle: event.eventName,
                    fallbackWidget: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: AppColors.primary.getByBrightness(brightness),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded
                (
                  child: Column
                  (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Text
                      (
                        event.eventName,
                        style: const TextStyle
                        (
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      
                      Text(
                        DateFormat
                        (
                          'yyyy/MM/dd',
                        ).format(DateTime.parse(event.eventDate)),
                        style: TextStyle
                        (
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                          fontSize: 12,
                        ),
                      ),
                    
                    ],
                  ),
                ),
                
                Icon
                (
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.w_b.getByBrightness(brightness),
                ),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClientEmptyEvents extends StatelessWidget 
{
  const ClientEmptyEvents({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Container
    (
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration
      (
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
      ),
      child: Column
      (
        children: <Widget>
        [
          Icon(Icons.event_busy_rounded, size: 48, color: AppColors.w_b.getByBrightness(brightness).withValues(alpha: 0.1)),
          const SizedBox(height: 16),

          Text
          (
            'لا توجد مناسبات لهذا العميل',
            style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
        
        ],
      ),
    );
  }
}
