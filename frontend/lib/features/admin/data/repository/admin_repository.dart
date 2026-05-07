import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/auth_service.dart';
import '../models/admin_models.dart';

class AdminRepository {
  Future<List<SystemUser>> getSystemUsers() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/system_users'),
      headers: {'Authorization': 'Bearer ${AuthService.token}', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      data = data['data'] ?? data['result'] ?? data;
      return data.map((e) => SystemUser.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load system users');
    }
  }

  Future<void> toggleUserStatus(int userId, bool isActive) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiEndpoints.users}/$userId/set_active'),
      headers: {'Authorization': 'Bearer ${AuthService.token}', 'Content-Type': 'application/json'},
      body: jsonEncode({'is_active': isActive}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update user status');
    }
  }

  Future<List<Role>> getRoles() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/roles'),
      headers: {'Authorization': 'Bearer ${AuthService.token}', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      data = data['data'] ?? data['result'] ?? data;
      return data.map((e) => Role.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load roles');
    }
  }

  Future<void> changeUserRole(int userId, int roleId) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/system_users/$userId/role'),
      headers: {'Authorization': 'Bearer ${AuthService.token}', 'Content-Type': 'application/json'},
      body: jsonEncode({'role_id': roleId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user role');
    }
  }
}
