
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/auth_service.dart';
import '../../../../core/controllers/validtor.dart' show MyPValidator;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../core/utils/utils.dart' show MyPUtils;
import '../../shared/controllers/user_controller.dart';
import '../../shared/data/repository/user_repository.dart';
import '../data/models/client.dart' show Client;
import '../../events/data/models/event.dart' show Event;
import '../../events/controller/event_controller.dart' show EventController;
import '../provider/client_provider.dart' show ClientProvider;

class ClientController extends GenericUserController<Client> 
{
  ClientController() : 
    super(repository: UserRepository<Client>(
      provider: Get.find<ClientProvider>(),
      fromJson: (json) => Client.fromJson(json),
    ));
  
  final EventController _eventController = Get.find<EventController>();
  
  final nameRx = ''.obs;
  final phoneRx = ''.obs;
  final emailRx = ''.obs;
  final addressRx = ''.obs;
  final currentFilter = 'الكل'.obs;
  final selectedClient = Rxn<Client>();
  
  /// Compatibility getter
  List<Client> get clients => list;
  
  Client? _initialClient;
  RxBool get eventsIsLoading => _eventController.isLoading;

  @override
  void onInit() {
    super.onInit();
    _eventController.fetchAll();
  }

  void clearFields() {
    nameRx.value = '';
    phoneRx.value = '';
    emailRx.value = '';
    addressRx.value = '';
    profileImage.value = null;
  }

  void populateFields(Client client) {
    nameRx.value = client.name;
    phoneRx.value = client.phoneNumber;
    emailRx.value = client.email ?? '';
    addressRx.value = client.address ?? '';
    _initialClient = client;
  }

  List<Client> get filteredClients {
    return getFilteredList((c, query) {
      bool matchesSearch = c.name.toLowerCase().contains(query) || c.phoneNumber.contains(query);
      bool matchesFilter = true;
      
      matchesFilter = switch(currentFilter.value){
        'نشط' => c.isActive == true && c.isDeleted != true,
        'المؤرشف' => c.isDeleted,
        'كبار الشخصيات' => c.name.toLowerCase().contains('vip'),
        _=> matchesFilter
      };
      return matchesSearch && matchesFilter;
    });
  }

  Future<void> fetchClient(int id) async {
    await fetchById(id);
  }

  Future<void> createClient() async {
    if(isLoading.value) return;
    var contactMsg = MyPValidator.cocatMsg([
      MyPValidator.name(nameRx.value),
      MyPValidator.email(emailRx.value),
      MyPValidator.phone(phoneRx.value),
    ]); 
    if(contactMsg != null) {
      return MyPUtils.showSnackbar('تنبيه', contactMsg, isError: true, position: SnackPosition.TOP,
        icon: Icon(Icons.warning_amber_rounded, color: AppColors.accent.getByBrightness(Get.theme.brightness)));
    }
    isLoading.value = true;

    (await repository.create(dio.FormData.fromMap({
      'full_name': nameRx.value,
      'phone_number': phoneRx.value,
      'email': emailRx.value,
      'address': addressRx.value,
      'coordinator_email': AuthService.user.value.email,
      if (profileImage.value != null) 'img_url': await dio.MultipartFile.fromFile(
        profileImage.value!.path,
        filename: profileImage.value!.path.split('/').last,
      ),
    }))).fold(
      (error) {
        Get.log('❌ createClient failed: ${error.message}');
        MyPUtils.showSnackbar('خطأ', error.message, isError: true);
        return false;
      },
      (response) async{
        Get.log('✅ createClient success: ${response.id}');
        list.add(response);
        Get.log('🔙 Calling Get.back()');
        Get.back();
        // MyPUtils.showSnackbar('نجاح', 'تم إضافة العميل بنجاح');
        clearFields();
        return true;
      },
    );
    isLoading.value = false;
  }

  Future<void> updateClient(int id) async {
    if(isLoading.value) return;
    if (_initialClient != null) {
      
      if (!(nameRx.value != _initialClient!.name ||
                       phoneRx.value != _initialClient!.phoneNumber ||
                       emailRx.value != (_initialClient!.email ?? '') ||
                       addressRx.value != (_initialClient!.address ?? '') ||
                       profileImage.value != null)) {
        Get.log('ℹ️ No changes detected, calling Get.back()');
        Get.back();
        return;
      }
    }

    isLoading.value = true;
    final result = (await repository.update(id, 
      dio.FormData.fromMap({
        'full_name': nameRx.value,
        'phone_number': phoneRx.value,
        'email': emailRx.value,
        'address': addressRx.value,
        'coordinator_email': AuthService.user.value.email,
        if (profileImage.value != null) 'img_url': await dio.MultipartFile.fromFile(
          profileImage.value!.path,
          filename: profileImage.value!.path.split('/').last,
        ),
      })
    ));
    if(result.isSuccess){
      final updated = result.data;
       Get.log('✅ updateClient success: ${updated?.id}');
        final index = list.indexWhere((c) => c.id == id);
        if (index != -1 && updated != null) list[index] = updated;
        selectedClient.value = updated;
        Get.log('🔙 Calling Get.back()');
        Get.back();
        // MyPUtils.showSnackbar('نجاح', 'تم تحديث البيانات');
        clearFields();
    }
    else {
      Get.log('❌ updateClient failed: ${result.failure?.message}');
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    // .fold(
    //   (error) {
    //     Get.log('❌ updateClient failed: ${error.message}');
    //     MyPUtils.showSnackbar('خطأ', error.message, isError: true);
    //   },
    //   (updated) {
       
    //   },
    // );
    isLoading.value = false;
  }

  Event? getLastEventForClient(int clientId) {
    final clientEvents = _eventController.events.where((e) => e.clientId == clientId).toList();
    if (clientEvents.isEmpty) return null;
    
    // Sort by date or ID as a proxy for date if date parsing is complex
    clientEvents.sort((a, b) => b.id.compareTo(a.id)); 
    return clientEvents.first;
  }

  Future<void> deleteClient(int id) async {
    await delete(id);
    final index = list.indexWhere((c) => c.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(isDeleted: true);
    }
  }

  Future<void> restoreClient(int id) async {
    isLoading.value = true;
    final result = await repository.restore(id);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        final index = list.indexWhere((c) => c.id == id);
        if (index != -1) {
          list[index] = list[index].copyWith(isDeleted: false);
        }
        // MyPUtils.showSnackbar('نجاح', 'تم استعادة العميل');
      },
    );
    isLoading.value = false;
  }
}
