import 'dart:convert';
import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:ecochallenge_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static String? username;
  static String? password;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String user, String pass) async {
    final url = Uri.parse('http://10.0.2.2:5087/api/Users/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({'username': user, 'password': pass}),
    );

    if (response.statusCode == 200) {
      // optionally parse user info if returned
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode({'username': user}));
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
    await prefs.remove('userData');
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
