import 'dart:convert';
import 'dart:io';

import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<UserResponse> {
  UserProvider() : super("Users");

  @override
  UserResponse fromJson(data) {
    return UserResponse.fromJson(data);
  }

  // The delete and getById methods are now inherited from BaseProvider
  // You can add user-specific methods here if needed
  
  Future<UserResponse> updateUserStatus(int id, bool isActive) async {
    var request = {'isActive': isActive};
    return await update(id, request);
  }

}
