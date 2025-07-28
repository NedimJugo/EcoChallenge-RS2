import 'dart:convert';
import 'dart:io';
import 'package:ecochallenge_mobile/pages/search_result.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://10.0.2.2:5087/api/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    // Ensure proper URL formatting
    var baseUrl = _baseUrl!.endsWith('/')
        ? _baseUrl!.substring(0, _baseUrl!.length - 1)
        : _baseUrl;
    var endpoint = _endpoint.startsWith('/')
        ? _endpoint.substring(1)
        : _endpoint;
    var url = "$baseUrl/$endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    print("Full URL being called: $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    print("Response status: ${response.statusCode}");
    print("Response headers: ${response.headers}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<T>();
      result.totalCount = data['totalCount'];
      result.items = List<T>.from(data["items"].map((e) => fromJson(e)));
      return result;
    } else {
      throw new Exception("Unknown error");
    }
  }

  // JSON-only insert method
  Future<T> insert(dynamic request) async {
    var baseUrl = _baseUrl!.endsWith('/')
        ? _baseUrl!.substring(0, _baseUrl!.length - 1)
        : _baseUrl;
    var endpoint = _endpoint.startsWith('/')
        ? _endpoint.substring(1)
        : _endpoint;
    var url = "$baseUrl/$endpoint";
    
    print("POST URL (JSON): $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    headers['Content-Type'] = 'application/json';
    
    var jsonRequest = jsonEncode(request);
    print("JSON Request body: $jsonRequest");
    
    var response = await http.post(uri, headers: headers, body: jsonRequest);
    
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  // Multipart/form-data insert method for file uploads
  Future<T> insertWithFiles(dynamic request, {List<File>? files}) async {
    var baseUrl = _baseUrl!.endsWith('/')
        ? _baseUrl!.substring(0, _baseUrl!.length - 1)
        : _baseUrl;
    var endpoint = _endpoint.startsWith('/')
        ? _endpoint.substring(1)
        : _endpoint;
    var url = "$baseUrl/$endpoint";
    
    print("POST URL (Multipart): $url");
    var uri = Uri.parse(url);
    
    // Create multipart request for form-data
    var multipartRequest = http.MultipartRequest('POST', uri);
    
    // Add authentication header
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    print("Using credentials: $username, $password");
    
    if (username.isNotEmpty && password.isNotEmpty) {
      String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
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
            'Photos', // This matches your backend property name
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
        throw Exception("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Request failed: $e");
      throw Exception("Network error: $e");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var baseUrl = _baseUrl!.endsWith('/')
        ? _baseUrl!.substring(0, _baseUrl!.length - 1)
        : _baseUrl;
    var endpoint = _endpoint.startsWith('/')
        ? _endpoint.substring(1)
        : _endpoint;
    var url = "$baseUrl/$endpoint/$id";
    
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized - Check your credentials");
    } else if (response.statusCode == 415) {
      throw Exception("Unsupported Media Type - Server expects different content type");
    } else {
      print("Error response body: ${response.body}");
      throw Exception("Server error ${response.statusCode}: ${response.body}");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";
    print("passed creds: $username, $password");

    var headers = <String, String>{
      "Accept": "application/json",
    };

    if (username.isNotEmpty && password.isNotEmpty) {
      String basicAuth = "Basic ${base64Encode(utf8.encode('$username:$password'))}";
      headers["Authorization"] = basicAuth;
    }

    return headers;
  }

  String getQueryString(
  Map params, {
  String prefix = '&',
  bool inRecursion = false,
}) {
  String query = '';
  params.forEach((key, value) {
    if (inRecursion) {
      if (key is int) {
        key = '[$key]';
      } else if (value is List || value is Map) {
        key = '.$key';
      } else {
        key = '.$key';
      }
    }
    if (value is String || value is int || value is double || value is bool) {
      var encoded = value;
      if (value is String) {
        encoded = Uri.encodeComponent(value);
      }
      query += '$prefix$key=$encoded';
    } else if (value is DateTime) {
      query += '$prefix$key=${value.toIso8601String()}';
    } else if (value is List || value is Map) {
      if (value is List) value = value.asMap();
      value.forEach((k, v) {
        query += getQueryString(
          {k: v},
          prefix: '$prefix$key',
          inRecursion: true,
        );
      });
    }
  });
  return query;
}
}
