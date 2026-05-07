import 'package:get/get.dart';
import '../data/models/admin_models.dart';
import '../data/repository/admin_repository.dart';
import '../../../../core/utils/utils.dart' show MyPUtils;

class AdminController extends GetxController {
  final AdminRepository repository;
  
  AdminController({required this.repository});

  var isLoadingUsers = false.obs;
  var isLoadingRoles = false.obs;
  
  RxList<SystemUser> usersList = <SystemUser>[].obs;
  RxList<Role> rolesList = <Role>[].obs;

  final userSearchQuery = ''.obs;
  final roleSearchQuery = ''.obs;

  List<SystemUser> get filteredUsers => usersList.where((u) {
    final query = userSearchQuery.value.toLowerCase();
    return u.fullName.toLowerCase().contains(query) || 
           u.email.toLowerCase().contains(query);
  }).toList();

  List<Role> get filteredRoles => rolesList.where((r) {
    final query = roleSearchQuery.value.toLowerCase();
    return r.roleName.toLowerCase().contains(query);
  }).toList();

  @override
  void onInit() {
    super.onInit();
    fetchSystemUsers();
    fetchRoles();
  }

  void fetchSystemUsers() async {
    isLoadingUsers.value = true;
    try {
      final data = await repository.getSystemUsers();
      usersList.assignAll(data);
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', e.toString(), isError: true);
    } finally {
      isLoadingUsers.value = false;
    }
  }

  void fetchRoles() async {
    isLoadingRoles.value = true;
    try {
      final data = await repository.getRoles();
      rolesList.assignAll(data);
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', e.toString(), isError: true);
    } finally {
      isLoadingRoles.value = false;
    }
  }

  Future<void> toggleUserStatus(int userId, bool currentStatus) async {
    try {
      await repository.toggleUserStatus(userId, !currentStatus);
      MyPUtils.showSnackbar('نجاح', 'تم تغيير حالة المستخدم بنجاح');
      fetchSystemUsers(); // Refresh
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', e.toString(), isError: true);
    }
  }

  Future<void> changeUserRole(int userId, int newRoleId) async {
    try {
      await repository.changeUserRole(userId, newRoleId);
      MyPUtils.showSnackbar('نجاح', 'تم تغيير الدور بنجاح');
      fetchSystemUsers(); // Refresh
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', e.toString(), isError: true);
    }
  }
}
