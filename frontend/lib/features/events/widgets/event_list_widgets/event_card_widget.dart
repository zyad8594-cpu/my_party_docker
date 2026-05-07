
part of 'list_widgets.dart';


class EventCard extends StatelessWidget {
  final Event event;
  final EventController controller;

  const EventCard({super.key, required this.event, required this.controller});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    final statusColor = event.status.tryColor(brightness);
    final statusText = event.status.tryText();
    final isCancelled = event.status.isCancelled;

    return Stack(
      children: [
        Container
        (
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration
          (
            color: AppColors.surface.getByBrightness(brightness),
            borderRadius: BorderRadius.circular(24),
            boxShadow: 
            [
              BoxShadow
              (
                color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all
            (
              color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.05),
              width: 1,
            ),
          ),

          /**
           *         بطاقة المناسبة
           */
          child: Material
          (
            color: AppColors.transparent,
            child: InkWell
            (
              // عند الظغط على البطاقة نذهب الى صفحة تفاصيل المناسبة
              // onTap: ()=> isCancelled? null : Get.toNamed(AppRoutes.eventDetail, arguments: event),
              onTap: ()=> Get.toNamed(AppRoutes.eventDetail, arguments: event),
              borderRadius: BorderRadius.circular(24), // جعل الحواف دائرية
              child: Padding
              (
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // حاوية ايقونة المناسبة
                    _eventCardIcon(context, color: statusColor),
                    const SizedBox(width: 16),

                    // بقية المعلومات
                    _buildEventCardBody(event, brightness, statusText: statusText, statusColor: statusColor),
                    
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // if(isCancelled) IconButton(
                        //   onPressed: ()=> EventListWidgets.showRestoreDialog(context, event.id, controller),
                        //   icon: Icon(
                        //     Icons.undo_rounded,
                        //     size: 20,
                        //     color: AppColors.primary.getByBrightness(brightness),
                        //   ),
                        //   tooltip: 'تراجع',
                        // ),
                        if(!isCancelled && !event.status.isCompleted && !event.isDeleted) _buildActionButtons([
                          _buildActionButton(context, 'تعديل', 
                            icon: Icons.edit, 
                            color: AppColors.warning, 
                            onTap: ()=>Get.toNamed(AppRoutes.eventAdd, arguments:  event,),
                          ),
                          _buildActionButton(context, 'إلغاء', 
                            icon: Icons.clear, 
                            color: AppColors.accent, 
                            onTap: ()=>EventListWidgets.showDeleteDialog(context, event.id, controller,)
                          )
                        ]),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _eventCardIcon(
    BuildContext context,{
    Color? color,
    double width = 60,
    double height = 60,
    double iconSize = 30,
    
  })
  {
    final brightness = Theme.of(context).brightness;
    return Container
                (
                  width: width,
                  height: height,
                  decoration: BoxDecoration
                  (
                    color: color?.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  /**
                   *         ايقونة المناسبة
                   */
                  child: Stack(
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
                            child: event.imgUrl.isNotEmpty
                                ? AppImage.network(
                                    event.imgUrl, 
                                    fit: BoxFit.cover, 
                                    viewerTitle: event.eventName,
                                    fallbackWidget: Icon(
                                      Icons.celebration_rounded,
                                      color: color,
                                      size: iconSize,
                                    ),
                                  )
                                : Icon(
                                    Icons.celebration_rounded,
                                    color: color,
                                    size: iconSize,
                                  ),
                          ),
                        ),
                      
                      ],
                    ) ,
                );
  }

  Widget _buildEventCardBody(Event event, Brightness brightness, {
    required String statusText,
    required Color statusColor,
  })
  {
    return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  اسم المناسبة وحالتها
                      _buildDetailOnEventCard(
                        event.eventName,
                        brightness, fontSize: 16, fontWeight: FontWeight.bold,
                        textColor: AppColors.textBody,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //  حالة المناسبة
                        children: [_buildStatusBadge(statusText, statusColor),]
                      ),
                      const SizedBox(height: 8),

                      //  إسم العميل
                      _buildDetailOnEventCard(
                        event.clientName,
                        brightness,
                        icon: Icons.person_rounded,
                      ),
                      //  مكان المناسبة
                      _buildDetailOnEventCard(
                        event.location ?? 'غير محدد',
                        brightness,
                        icon: Icons.location_on_rounded,
                      ),
                      // تأريخ المناسبة
                      _buildDetailOnEventCard(
                          DateFormat('yyyy/MM/dd','ar',).format(DateTime.tryParse(event.eventDate) ?? DateTime.now()),
                          brightness, 
                          icon: Icons.calendar_month_rounded,
                          isExpanded: false
                        ),
                      
                    ],
                  ),
                );
  }
  //         حالة المناسبة
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDetailOnEventCard(
    String text, Brightness brightness,{
      IconData? icon, 
      bool isExpanded = true,
      double fontSize = 12,
      FontWeight? fontWeight,
      double iconSize = 14,
      AppColorSet<Color>? iconColor,
      AppColorSet<Color>? textColor,
      TextOverflow textOverflow = TextOverflow.ellipsis,
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
      List<Widget> children = const <Widget>[]
  })
  {
    final textWidget =  Text(text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: (textColor ?? AppColors.textSubtitle).getByBrightness(brightness),
      ),
      overflow: textOverflow,
    );
            
    return  Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (icon != null) Icon(icon, size: iconSize,
          color: (iconColor ?? AppColors.textSubtitle).getByBrightness(brightness),
        ),
        if(icon != null) const SizedBox(width: 4),
        isExpanded ? Expanded(child: textWidget) : textWidget,
        ...children,
      ]
    );
  }

  Widget _buildActionButtons(List<PopupMenuItem<String>> items)
  {
    return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) => items,
    );
  }

  PopupMenuItem<String> _buildActionButton(
    BuildContext context, 
    String value, {
      IconData? icon, AppColorSet<Color>? color, 
      double iconSize = 18, 
      double? fontSize,
      void Function()? onTap
    })
  {
    final brightness = Theme.of(context).brightness;
    return PopupMenuItem<String>(
              value: value,
              onTap: onTap,
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (icon != null)Icon(icon, color: color?.getByBrightness(brightness), size: iconSize),
                  Text(value, style: TextStyle(fontSize: fontSize, color: color?.getByBrightness(brightness))),
                ],
              ),
            );
  }

}

  