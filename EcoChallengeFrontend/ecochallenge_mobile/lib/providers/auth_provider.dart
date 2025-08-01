import 'dart:convert';
import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:ecochallenge_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static String? username;
  static String? password;
  static UserResponse? userData;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

   UserResponse? get currentUser => userData;
    int? get currentUserId => userData?.id;

  Future<void> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    password = prefs.getString('password');

     // Load user data if exists
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      try {
        userData = UserResponse.fromJson(jsonDecode(userDataString));
      } catch (e) {
        print('Error loading user data: $e');
      }
    }

    if (username != null && password != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(String user, String pass) async {
    final url = Uri.parse('http://10.0.2.2:5087/api/Users/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({'username': user, 'password': pass}),
    );

    if (response.statusCode == 200) {
      final userJson = jsonDecode(response.body);
      userData = UserResponse.fromJson(userJson);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user);
      await prefs.setString('password', pass);
      await prefs.setString('userData', response.body);
      _isLoggedIn = true;
      username = user;
      password = pass;
      notifyListeners();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('userData');
    username = null;
    password = null;
    _isLoggedIn = false;
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
