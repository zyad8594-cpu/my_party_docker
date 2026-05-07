import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/components/app_image.dart';
import '../../../../core/api/api_constants.dart';
import '../../../events/data/models/event.dart';
import '../../../clients/controller/client_controller.dart';
import '../../../../core/components/widgets/app_detail_widgets.dart';

class EventClientSection extends StatelessWidget {
  final Event? event;

  const EventClientSection({
    super.key,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppDetailWidgets.buildInfoCard(
      context,
      title: 'بيانات المناسبة والعميل',
      icon: Icons.event_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventDetails(context, brightness),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          _buildClientDetails(context, brightness),
        ],
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context, Brightness brightness) {
    if (event == null) {
      return Text(
        'جاري التحميل...',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.getByBrightness(brightness),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event!.imgUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                AppImage.network(
                  event!.imgUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallbackWidget: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    event!.eventName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: AppColors.black54, blurRadius: 8)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else ...[
          Text(
            event!.eventName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary.getByBrightness(brightness),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            _buildCompactDetail(context, Icons.location_on_outlined, event!.location ?? 'غير محدد'),
            const SizedBox(width: 16),
            _buildCompactDetail(context, Icons.calendar_today_outlined, DateFormatter.format(event!.eventDate)),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [_buildCompactDetail(context, Icons.timer_outlined, '${event!.eventDuration} ${event!.eventDurationUnit}')]),
      ],
    );
  }

  Widget _buildClientDetails(BuildContext context, Brightness brightness) {
    if (event == null) return const SizedBox.shrink();

    // Fix: Use ClientController to get accurate data for coordinators if availabe
    return GetX<ClientController>(
      builder: (clientController) {
        final client = clientController.clients.firstWhereOrNull((c) => c.id == event!.clientId);
        
        final String name = client?.name ?? event!.clientName;
        final String phone = client?.phoneNumber ?? event!.clientPhone;
        final String email = client?.email ?? event!.clientEmail;
        final String img = client?.imgUrl ?? event!.clientImg;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: AppImage.network(
                      img.startsWith('http') 
                          ? img 
                          : '${ApiConstants.baseUrl.replaceAll('/api', '')}/uploads/$img',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      viewerTitle: name,
                      fallbackWidget: AppImage.getAvatarFallback(brightness: brightness, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'غير محدد' : name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBody.getByBrightness(brightness),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'العميل للمناسبة',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (phone.isNotEmpty)
              _buildContactInfo(context, Icons.phone_android_rounded, 'الهاتف:', phone),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildContactInfo(context, Icons.email_outlined, 'البريد:', email),
            ],
          ],
        );
      }
    );
  }

  Widget _buildCompactDetail(BuildContext context, IconData icon, String value) {
    final brightness = Theme.of(context).brightness;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary.getByBrightness(brightness)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String label, String value) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSubtitle.getByBrightness(brightness),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textBody.getByBrightness(brightness),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
