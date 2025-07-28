import 'dart:convert';
import 'package:ecochallenge_desktop/models/search_result.dart';
import 'package:ecochallenge_desktop/providers/admin_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";
  static String get baseUrl => _baseUrl!;

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5087/api/",
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
    // print("response: ${response.request} ${response.statusCode}, ${response.body}");
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
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


  // Add delete method to base provider
  Future<void> delete(int id) async {
    var baseUrl = _baseUrl!.endsWith('/')
        ? _baseUrl!.substring(0, _baseUrl!.length - 1)
        : _baseUrl;
    var endpoint = _endpoint.startsWith('/')
        ? _endpoint.substring(1)
        : _endpoint;
    var url = "$baseUrl/$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    if (!isValidResponse(response)) {
      throw Exception("Failed to delete item");
    }
  }

  // Add getById method to base provider
  Future<T> getById(int id) async {
    var baseUrl = _baseUrl!.endsWith('/')
        ? _baseUrl!.substring(0, _baseUrl!.length - 1)
        : _baseUrl;
    var endpoint = _endpoint.startsWith('/')
        ? _endpoint.substring(1)
        : _endpoint;
    var url = "$baseUrl/$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.get(uri, headers: headers);
    
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to get item");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      print("Error response body: ${response.body}");
      throw Exception("Something bad happened please try again");
    }
  }

  Map<String, String> createHeaders() {
     String username = AdminAuthProvider.username ?? "";
     String password = AdminAuthProvider.password ?? "";

  print("passed creds: $username, $password");

    // String username = AuthModel.username ?? "";
    // String password = AuthModel.password ?? "";

    // print("passed creds: $username, $password");

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

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
