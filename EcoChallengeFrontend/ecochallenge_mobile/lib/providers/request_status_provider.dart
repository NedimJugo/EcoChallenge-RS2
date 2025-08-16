// request_status_provider.dart
import 'dart:convert';

import 'package:ecochallenge_mobile/models/request_status.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class RequestStatusProvider extends BaseProvider<RequestStatusResponse> {
  RequestStatusProvider() : super("RequestStatus");

  @override
  RequestStatusResponse fromJson(data) {
    return RequestStatusResponse.fromJson(data);
  }

  Future<RequestStatusResponse> insertRequestStatus(RequestStatusInsertRequest request) async {
    return await super.insert(request);
  }

  Future<RequestStatusResponse> updateRequestStatus(int id, RequestStatusUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<RequestStatusResponse>> getByName(String name) async {
    final searchObject = RequestStatusSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<RequestStatusResponse>> getAll() async {
    final searchObject = RequestStatusSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<RequestStatusResponse?> getById(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.get(uri, headers: headers);
    
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    }
    return null;
  }

  Future<bool> deleteRequestStatus(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}