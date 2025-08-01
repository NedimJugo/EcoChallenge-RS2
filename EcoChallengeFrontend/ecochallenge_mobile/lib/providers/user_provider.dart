import 'dart:convert';
import 'dart:io';
import 'package:ecochallenge_mobile/models/user.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<UserResponse> {
  UserProvider() : super("Users");

  @override
  UserResponse fromJson(data) {
    return UserResponse.fromJson(data);
  }

  // ADD THIS METHOD - Get user by ID directly
  Future<UserResponse?> getUserById(int userId) async {
    var baseUrl = this.baseUrl;
    var endpoint = this.endpoint;
    var url = "$baseUrl/$endpoint/$userId";
    
    print("GET User by ID URL: $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    try {
      var response = await http.get(uri, headers: headers);
      print("Get user by ID response status: ${response.statusCode}");
      print("Get user by ID response body: ${response.body}");
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else if (response.statusCode == 404) {
        print("User with ID $userId not found");
        return null;
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Get user by ID request failed: $e");
      throw Exception("Network error: $e");
    }
  }

  // ... rest of your existing methods remain the same
  
  @override
  Future<UserResponse> update(int id, [dynamic request]) async {
    var baseUrl = this.baseUrl;
    var endpoint = this.endpoint;
    var url = "$baseUrl/$endpoint/$id";
    print("PUT URL (Multipart): $url");
    var uri = Uri.parse(url);
    
    // Create multipart request
    var multipartRequest = http.MultipartRequest('PUT', uri);
    
    // Add authentication header
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    print("Using credentials: $username, $password");
    
    if (username.isNotEmpty && password.isNotEmpty) {
      String basicAuth =
          "Basic ${base64Encode(utf8.encode('$username:$password'))}";
      multipartRequest.headers['Authorization'] = basicAuth;
    }
    
    // Add form fields from request object
    if (request != null) {
      var requestMap = request.toJson();
      requestMap.forEach((key, value) {
        if (value != null) {
          if (value is DateTime) {
            multipartRequest.fields[key] = value.toIso8601String();
          } else if (value is List) {
            // Skip lists (like photoUrls) since we're sending files directly
            return;
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        }
      });
    }
    
    print("Request fields: ${multipartRequest.fields}");
    
    try {
      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception(
          "Server error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Request failed: $e");
      throw Exception("Network error: $e");
    }
  }

  Future<UserResponse> updateWithFiles(
    int id,
    dynamic request, {
    List<File>? files,
  }) async {
    var baseUrl = this.baseUrl;
    var endpoint = this.endpoint;
    var url = "$baseUrl/$endpoint/$id";
    print("PUT URL (Multipart with files): $url");
    var uri = Uri.parse(url);
    
    // Create multipart request
    var multipartRequest = http.MultipartRequest('PUT', uri);
    
    // Add authentication header
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    print("Using credentials: $username, $password");
    
    if (username.isNotEmpty && password.isNotEmpty) {
      String basicAuth =
          "Basic ${base64Encode(utf8.encode('$username:$password'))}";
      multipartRequest.headers['Authorization'] = basicAuth;
    }
    
    // Add form fields from request object
    if (request != null) {
      var requestMap = request.toJson();
      requestMap.forEach((key, value) {
        if (value != null) {
          if (value is DateTime) {
            multipartRequest.fields[key] = value.toIso8601String();
          } else if (value is List) {
            // Skip lists (like photoUrls) since we're sending files directly
            return;
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        }
      });
    }
    
    // Add files if provided
    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        var file = files[i];
        try {
          var multipartFile = await http.MultipartFile.fromPath(
            'ProfileImageUrl', // This matches your backend property name
            file.path,
          );
          multipartRequest.files.add(multipartFile);
          print("Added file: ${file.path}");
        } catch (e) {
          print("Error adding file ${file.path}: $e");
        }
      }
    }
    
    print("Request fields: ${multipartRequest.fields}");
    print("Request files count: ${multipartRequest.files.length}");
    
    try {
      var streamedResponse = await multipartRequest.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      
      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw Exception(
          "Server error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("Request failed: $e");
      throw Exception("Network error: $e");
    }
  }

  Future<List<UserResponse>> getLeaderboardUsers() async {
    final result = await this.get(
      filter: {
        "orderBy": "totalPoints",
        "sortDirection": "desc",
        "pageSize": 100,
      },
    );
    return result.items ?? <UserResponse>[];
  }
}
