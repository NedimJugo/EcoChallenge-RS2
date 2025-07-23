import 'dart:convert';
import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthProvider with ChangeNotifier {
  static String? username;
  static String? password;
  UserResponse? userData;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
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
    final url = Uri.parse('$baseUrl/Users/admin-login');

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

}
