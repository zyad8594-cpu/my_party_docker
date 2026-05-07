import 'package:flutter/material.dart';
import '../../../core/api/auth_service.dart';
import 'task_list_screen.dart';
import '../../suppliers/views/supplier_task_list_screen.dart';

class RoleBasedTaskListScreen extends StatelessWidget {
  const RoleBasedTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = AuthService.user.value.role;

    if (role.toString().toLowerCase() == 'supplier') {
      return SupplierTaskListScreen();
    } else {
      return TaskListScreen();
    }
  }
}
