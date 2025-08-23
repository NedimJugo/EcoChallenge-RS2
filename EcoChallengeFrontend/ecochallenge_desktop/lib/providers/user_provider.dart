import 'dart:convert';

import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;


class UserProvider extends BaseProvider<UserResponse> {
  UserProvider() : super("Users");

  @override
  UserResponse fromJson(data) {
    return UserResponse.fromJson(data);
  }

  @override
  Future<UserResponse> insert(dynamic request) async {
    var url = "$baseUrl/$endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var multipartRequest = http.MultipartRequest("POST", uri);
    multipartRequest.headers.addAll(headers);

    // Add fields from request (UserInsertRequest.toJson())
    request.forEach((key, value) {
      if (value != null) {
        if (value is DateTime) {
          multipartRequest.fields[key] = value.toIso8601String();
        } else {
          multipartRequest.fields[key] = value.toString();
        }
      }
    });

    var streamedResponse = await multipartRequest.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Insert failed: ${response.body}");
    }
  }

  @override
  Future<UserResponse> update(int id, [dynamic request]) async {
    var url = "$baseUrl/$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var multipartRequest = http.MultipartRequest("PUT", uri);
    multipartRequest.headers.addAll(headers);

    request.forEach((key, value) {
      if (value != null) {
        if (value is DateTime) {
          multipartRequest.fields[key] = value.toIso8601String();
        } else {
          multipartRequest.fields[key] = value.toString();
        }
      }
    });

    var streamedResponse = await multipartRequest.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Update failed: ${response.body}");
    }
  }

  
  Future<UserResponse> updateUserStatus(int id, bool isActive) async {
    var request = {'isActive': isActive};
    return await update(id, request);
  }

}
