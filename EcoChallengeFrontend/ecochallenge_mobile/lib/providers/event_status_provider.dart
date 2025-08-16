// event_status_provider.dart
import 'dart:convert';

import 'package:ecochallenge_mobile/models/event_status.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class EventStatusProvider extends BaseProvider<EventStatusResponse> {
  EventStatusProvider() : super("EventStatus");

  @override
  EventStatusResponse fromJson(data) {
    return EventStatusResponse.fromJson(data);
  }

  Future<EventStatusResponse> insertEventStatus(EventStatusInsertRequest request) async {
    return await super.insert(request);
  }

  Future<EventStatusResponse> updateEventStatus(int id, EventStatusUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<EventStatusResponse>> getByName(String name) async {
    final searchObject = EventStatusSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<EventStatusResponse>> getAll() async {
    final searchObject = EventStatusSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<EventStatusResponse?> getById(int id) async {
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

  Future<bool> deleteEventStatus(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}