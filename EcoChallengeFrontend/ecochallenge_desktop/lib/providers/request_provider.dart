
import 'dart:convert';

import 'package:ecochallenge_desktop/models/request.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RequestProvider extends BaseProvider<RequestResponse> {
  RequestProvider() : super("Request");

  @override
  RequestResponse fromJson(data) {
    return RequestResponse.fromJson(data);
  }

   @override
  Future<RequestResponse> update(int id, [dynamic request]) async {
    var baseUrl = BaseProvider.baseUrl.endsWith('/')
        ? BaseProvider.baseUrl.substring(0, BaseProvider.baseUrl.length - 1)
        : BaseProvider.baseUrl;
    var endpoint = "Request"; // Your endpoint
    var url = "$baseUrl/$endpoint/$id";
    var uri = Uri.parse(url);

    // Create multipart request
    var multipartRequest = http.MultipartRequest('PUT', uri);
    
    // Add authentication headers (but not Content-Type - it's set automatically)
    var headers = createHeaders();
    headers.remove('Content-Type'); // Remove this for multipart requests
    multipartRequest.headers.addAll(headers);

    // Convert request object to form fields
    if (request != null) {
      var jsonData = request.toJson();
      jsonData.forEach((key, value) {
        if (value != null) {
          // Handle different data types appropriately
          if (value is List) {
            // For lists, you might need to serialize as JSON string
            // or handle each item separately depending on your backend
            multipartRequest.fields[key] = jsonEncode(value);
          } else if (value is DateTime) {
            multipartRequest.fields[key] = value.toIso8601String();
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        }
      });
    }

    // Send the request
    var streamedResponse = await multipartRequest.send();
    var response = await http.Response.fromStream(streamedResponse);

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Update failed");
    }
  }
}
