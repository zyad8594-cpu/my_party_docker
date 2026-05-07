import 'package:get/get.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/utils/utils.dart';

class AdminDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = true.obs;
  
  final usersStats = {}.obs;
  final servicesStats = 0.obs;
  final proposalsStats = <String, int>{}.obs;
  final activationStats = <String, int>{}.obs; // New stats for activation
  final recentNotifications = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdminStats();
  }

  Future<void> fetchAdminStats() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/dashboard/admin_stats');
      
      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        usersStats.assignAll({
          'ADMIN': data['total_admins'] ?? 0,
          'COORDINATOR': data['total_coordinators'] ?? 0,
          'SUPPLIER': data['total_suppliers'] ?? 0,
        });
        
        servicesStats.value = data['total_services'] ?? 0;
        
        proposalsStats.assignAll({
          'total': data['total_suggestions'] ?? 0,
          'pending': data['pending_suggestions'] ?? 0,
          'approved': data['approved_suggestions'] ?? 0,
          'rejected': data['rejected_suggestions'] ?? 0,
        });

        activationStats.assignAll({
          'total_users': data['total_users'] ?? 0,
          'active_users': data['active_users'] ?? 0,
          'inactive_users': data['inactive_users'] ?? 0,
          'active_coordinators': data['active_coordinators'] ?? 0,
          'inactive_coordinators': data['inactive_coordinators'] ?? 0,
          'active_suppliers': data['active_suppliers'] ?? 0,
          'inactive_suppliers': data['inactive_suppliers'] ?? 0,
        });
      }

      try {
        final notifResponse = await _apiService.get('/notifications');
        if (notifResponse != null) {
          var list = notifResponse['data'] ?? notifResponse['result']?['data'] ?? (notifResponse is List ? notifResponse : []);
          if (list is List) {
            // Sort by creation date descending
            list = list.where((item) => item['is_read'] == 0 || item['is_read'] == false).toList();
            list.sort((a, b) {
              final dateA = a['created_at']?.toString() ?? '';
              final dateB = b['created_at']?.toString() ?? '';
              return dateB.compareTo(dateA);
            });

            final Map<String, dynamic> uniqueTypes = {};
            for (var item in list) {
              final type = item['type']?.toString() ?? 'SYSTEM';
              if (!uniqueTypes.containsKey(type)) {
                uniqueTypes[type] = item;
              }
            }
            
            recentNotifications.value = uniqueTypes.values.take(4).toList();
          }
        }
      } catch (_) {
        // Ignore notification fetch error if any
      }

    } catch (e) {
      MyPUtils.showSnackbar('خطأ', 'فشل جلب إحصائيات الداشبورد', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
