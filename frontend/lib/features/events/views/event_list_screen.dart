import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart' show StatusTools;
import '../data/models/event.dart' show Event;
import '../controller/event_controller.dart' show EventController;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/myp_actions.dart' show MyPActions;
import '../widgets/event_list_widgets/list_widgets.dart';
import '../../shared/widgets/base_list_screen.dart';

class EventListScreen extends BaseListScreen<Event, EventController> {
  const EventListScreen({super.key});

  @override
  String get title => 'المناسبات';

  @override
  String get searchPlaceholder => 'البحث عن مناسبة...';

  @override
  List<String> get filterNames => StatusTools.getAllStatusText(prepend: ['الكل'], remove: ['قيد المراجعة', 'معتمدة', 'مرفوضة']);


  @override
  void onFilterSelected(bool selected, String value) {
    if (selected) controller.selectedStatus.value = value;
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return MyPActions.floatButton(
      context,
      icon: Icons.add_rounded,
      heroTag: 'add_event',
      onPressed: () async{
        await Get.toNamed(AppRoutes.eventAdd);
        controller.list.refresh();
      },
    );
  }

  @override
  List<Event> getItems() => controller.filteredEvents;

  void deleteItem(Event item) => controller.deleteEvent(item.id);

  @override
  Widget buildListItem(BuildContext context, Event event) {
    return EventCard(event: event, controller: controller);
  }
}
