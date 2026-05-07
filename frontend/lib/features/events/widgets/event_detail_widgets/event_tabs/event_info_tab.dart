import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../../core/utils/translate_duration_unit.dart' show translateDurationUnit;
import '../../../data/models/event.dart' show Event;
import '../../../../../core/themes/app_colors.dart' show AppColors;
import '../detail_widgets.dart' show buildInfoCard, infoTile;

class EventInfoTab extends StatelessWidget {
  final Event event;

  const EventInfoTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildInfoCard(
            brightness,
            title: 'تفاصيل الموقع والزمان',
            items: [
              infoTile(
                Icons.person_rounded,
                'العميل',
                event.clientName,
                brightness,
              ),
              infoTile(
                Icons.calendar_today_rounded,
                'التاريخ',
                DateFormat(
                  'yyyy/MM/dd',
                  'ar',
                ).format(DateTime.tryParse(event.eventDate) ?? DateTime.now()),
                brightness,
              ),
              infoTile(
                Icons.timer_rounded,
                'المدة',
                translateDurationUnit(event.eventDurationUnit, event.eventDuration),
                brightness,
              ),
              infoTile(
                Icons.location_on_rounded,
                'الموقع',
                event.location ?? 'غير محدد',
                brightness,
              ),
              infoTile(
                Icons.payments_rounded,
                'الميزانية',
                '${event.budget.toStringAsFixed(2)} \$',
                brightness,
              ),
            ],
          ),
          const SizedBox(height: 16),

          buildInfoCard(
            brightness,
            title: 'الوصف',
            child: Text(
              event.description ?? 'لا يوجد وصف متاح هذه المناسبة.',
              style: TextStyle(
                color: AppColors.textBody.getByBrightness(brightness),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
