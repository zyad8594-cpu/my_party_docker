import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/components/app_image.dart';
import '../../../core/components/widgets/app_form_widgets.dart';

import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../../../data/models/user.dart' show User;

class UserCardWidget<Controller extends dynamic> extends GetView<Controller> {
  final VoidCallback onTap;
  final List popupItems;
  final IconData? fallbackIcon;
  final User user;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onTap,
    required this.popupItems,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppFormWidgets.cardDecoration(context),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(brightness),
                const SizedBox(width: 16),
                Expanded(child: _buildInfo(brightness)),
                _buildPopupMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Brightness brightness) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient.getByBrightness(brightness),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: user.imgUrl != null
            ? ClipOval(
                child: AppImage.network(
                  user.imgUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  viewerTitle: user.name,
                  fallbackWidget: _buildFallbackIcon(brightness),
                ),
              )
            : _buildFallbackIcon(brightness),
      ),
    );
  }

  Widget _buildFallbackIcon(Brightness brightness) {
    if (fallbackIcon != null) {
      return Icon(fallbackIcon, color: AppColors.white, size: 24);
    }
    return Text(
      user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?',
      style: TextStyle(
        color: AppColors.w_b.getByBrightness(brightness),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfo(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusTag(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSubtitle.getByBrightness(brightness),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: user.isActive ? AppColors.green.withValues(alpha: 0.1) : AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        user.isActive ? 'نشط' : 'معطل',
        style: TextStyle(
          color: user.isActive ? AppColors.green : AppColors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSubtitle.getByBrightness(brightness),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surface.getByBrightness(brightness),
      elevation: 4,
      onSelected: (value){
        final role = user.role.toLowerCase();
        final params = switch(value){
          'status' => (user.id, !user.isActive),
          'edit' => (role == 'supplier' ? AppRoutes.supplierAdd : AppRoutes.coordinatorAdd, user),
          'delete' => (user.id, context),
          _ => (null, null),
        };

        if (value == 'status') {
          controller.toggleStatus(params.$1 as int, params.$2 as bool);
        } else if (value == 'edit') {
          Get.toNamed(params.$1 as String, arguments: params.$2);
        } else if (value == 'delete') {
          _delete(params.$1 as int, arguments: params.$2 as BuildContext);
        }
      },
      itemBuilder: (context) => popupItems.map<PopupMenuEntry<String>>((item){
        return switch(item){
          PopupMenuEntry<String>() => item,
          Map<String, dynamic>() => PopupMenuItem(
            value: item['value'] ?? '',
            child: Row(
              children: [
                if(item['icon'] != null && (item['icon'] is IconData || item['icon'] is Widget)) ...[
                  item['icon'] is IconData ? Icon(item['icon'], color: item['color'], size: 18) : item['icon'] as Widget,
                  const SizedBox(width: 8),
                ],
                if(item['text'] != null && ((item['text'] is String && item['text'].isNotEmpty) || item['text'] is Widget)) 
                  item['text'] is String ? Text(item['text'], style: TextStyle(color: item['color'])) : item['text'] as Widget,
              ],
            ),
          ),
          _ => throw UnimplementedError(),
        };
      }).toList(),
    );
  }


  void _delete(int id, {required BuildContext arguments}) {
    MyPUtils.showConfirmDialog(
      context: arguments,
      title: 'حذف ${user.role == "supplier" ? "المورد" : "المنسق"}',
      message: 'هل أنت متأكد من حذف هذا ${user.role == "supplier" ? "المورد" : "المنسق"} نهائياً؟',
      confirmLabel: 'حذف',
      isDanger: true,
      onConfirm: () {
        controller.delete(id);
      },
    );
  }

  
}
