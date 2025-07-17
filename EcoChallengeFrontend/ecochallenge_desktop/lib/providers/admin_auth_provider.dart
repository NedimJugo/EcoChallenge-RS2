import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../layouts/constants.dart';
import '../models/admin_login_request.dart';
import '../models/admin_login_response.dart';

class AdminAuthService {
  static const String _credentialsKey = 'admin_basic_auth_credentials';
  static const String _adminDataKey = 'admin_data';

  Future<AdminLoginResponse?> login(AdminLoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/adminauth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final adminResponse = AdminLoginResponse.fromJson(responseData);

        // Store credentials and admin data locally
        await _storeCredentials(adminResponse.basicAuthCredentials);
        await _storeAdminData(adminResponse);

        return adminResponse;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<AdminProfileResponse?> getProfile() async {
    try {
      final credentials = await _getStoredCredentials();
      if (credentials == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/adminauth/profile'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AdminProfileResponse.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> validateAdmin() async {
    try {
      final credentials = await _getStoredCredentials();
      if (credentials == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/adminauth/validate'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final credentials = await _getStoredCredentials();

      if (credentials != null) {
        // Call logout endpoint
        await http.post(
          Uri.parse('$baseUrl/adminauth/logout'),
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/json',
          },
        );
      }
      await _clearStoredData();
      return true;
    } catch (e) {
      await _clearStoredData();
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final credentials = await _getStoredCredentials();
    if (credentials == null) return false;

    return await validateAdmin();
  }

  Future<AdminLoginResponse?> getStoredAdminData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminDataJson = prefs.getString(_adminDataKey);

      if (adminDataJson != null) {
        final adminData = jsonDecode(adminDataJson);
        return AdminLoginResponse(
          id: adminData['id'],
          username: adminData['username'],
          firstName: adminData['firstName'],
          lastName: adminData['lastName'],
          email: adminData['email'],
          userTypeName: adminData['userTypeName'],
          loginTime: DateTime.parse(adminData['loginTime']),
          basicAuthCredentials: adminData['basicAuthCredentials'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeCredentials(String credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsKey, credentials);
  }

  Future<void> _storeAdminData(AdminLoginResponse adminData) async {
    final prefs = await SharedPreferences.getInstance();
    final adminDataJson = jsonEncode({
      'id': adminData.id,
      'username': adminData.username,
      'firstName': adminData.firstName,
      'lastName': adminData.lastName,
      'email': adminData.email,
      'userTypeName': adminData.userTypeName,
      'loginTime': adminData.loginTime.toIso8601String(),
      'basicAuthCredentials': adminData.basicAuthCredentials,
    });
    await prefs.setString(_adminDataKey, adminDataJson);
  }

  Future<String?> _getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_credentialsKey);
  }

  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsKey);
    await prefs.remove(_adminDataKey);
  }
}
