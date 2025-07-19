import 'dart:convert';
import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  UserResponse? _currentUser;
  String? _token; // If your backend returns a token, store it here

  UserResponse? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null;


  AuthProvider() {
    _loadUserFromPreferences();
  }

  Future<void> _loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    final tokenData = prefs.getString('token'); // Load token if applicable

    if (userData != null) {
      _currentUser = UserResponse.fromJson(json.decode(userData));
    }
    if (tokenData != null) {
      _token = tokenData;
    }
    notifyListeners();
  }

  Future<void> _saveUserToPreferences(UserResponse user, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(user.toJson()));
    if (token != null) {
      await prefs.setString('token', token);
    }
  }

  Future<void> _removeUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove('token');
  }

  Future<UserResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/login'); // Adjust endpoint if needed

    // Encode credentials for Basic Auth
    final String credentials = base64Encode(utf8.encode('$username:$password'));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials', // Basic Auth header
    };

    try {
      // For Basic Auth, the credentials are in the header, so the body can be empty or contain other data if needed by your backend.
      // Based on your C# controller, it expects a UserLoginRequest in the body, so we'll keep it.
      // If your backend only uses the Basic Auth header and doesn't expect a body, you can remove the 'body' parameter.
      final body = json.encode(
        UserLoginRequest(username: username, password: password).toJson(),
      );

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final UserResponse user = UserResponse.fromJson(responseData);

        _currentUser = user;
        // If your backend returns a token, parse it from responseData and set _token
        // _token = responseData['token']; // Example if token is in response

        await _saveUserToPreferences(user, _token);
        notifyListeners();
        return user;
      } else {
        // Handle different error codes or parse error messages from backend
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to login. Please check your credentials.',
        );
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await _removeUserFromPreferences();
    notifyListeners();
  }
  Future<void> register(UserRegisterRequest request) async {
    final url = Uri.parse('$baseUrl/users/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception('Registration failed: ${response.body}');
    }
  }
}
