import 'dart:io';

import 'package:ecochallenge_mobile/models/request.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RequestProvider extends BaseProvider<RequestResponse> {
  RequestProvider() : super("Request");

  @override
  RequestResponse fromJson(data) {
    return RequestResponse.fromJson(data);
  }



  // Method to insert request without files (JSON only)
  Future<RequestResponse> insertRequest(RequestInsertRequest request) async {
    return await super.insert(request);
  }

   Future<RequestResponse> insertRequestWithFiles(
    RequestInsertRequest request, {
    List<File>? files,
  }) async {
    return await super.insertWithFiles(request, files: files);
  }

  // Method to update request
  Future<RequestResponse> updateRequest(int id, RequestUpdateRequest request) async {
    return await super.update(id, request);
  }

  // Method to delete request
  Future<bool> deleteRequest(int requestId) async {
    var baseUrl = this.baseUrl;
    var endpoint = this.endpoint;
    var url = "$baseUrl/$endpoint/$requestId";
    
    print("DELETE URL: $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    try {
      var response = await http.delete(uri, headers: headers);
      print("Delete response status: ${response.statusCode}");
      print("Delete response body: ${response.body}");
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception("Request not found");
      } else if (response.statusCode == 403) {
        throw Exception("You don't have permission to delete this request");
      } else if (response.statusCode == 400) {
        throw Exception("Cannot delete request - it may already be in review or approved");
      } else {
        throw Exception("Failed to delete request: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Delete request failed: $e");
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception("Network error: $e");
      }
    }
  }

  // Method to check if request can be deleted (only "To be reviewed" status)
  bool canDeleteRequest(RequestResponse request) {
    return request.statusId == 1; // Only "To be reviewed" status can be deleted
  }

  // Method to get user's requests with specific status
  Future<List<RequestResponse>> getUserRequestsByStatus(int userId, int statusId) async {
    final searchObject = RequestSearchObject(
      userId: userId,
      status: statusId,
      retrieveAll: true,
      sortBy: 'CreatedAt',
      desc: true,
    );

    final result = await get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  // Method to get all user's requests
  Future<List<RequestResponse>> getUserRequests(int userId) async {
    final searchObject = RequestSearchObject(
      userId: userId,
      retrieveAll: true,
      sortBy: 'CreatedAt',
      desc: true,
    );

    final result = await get(filter: searchObject.toJson());
    return result.items ?? [];
  }
}
