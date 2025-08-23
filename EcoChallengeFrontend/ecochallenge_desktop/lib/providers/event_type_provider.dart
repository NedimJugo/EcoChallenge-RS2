// event_type_provider.dart
import 'dart:convert';

import 'package:ecochallenge_desktop/models/event_type.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class EventTypeProvider extends BaseProvider<EventTypeResponse> {
  EventTypeProvider() : super("EventType");

  @override
  EventTypeResponse fromJson(data) {
    return EventTypeResponse.fromJson(data);
  }

  Future<EventTypeResponse> insertEventType(EventTypeInsertRequest request) async {
    return await super.insert(request);
  }

  Future<EventTypeResponse> updateEventType(int id, EventTypeUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<EventTypeResponse>> getByName(String name) async {
    final searchObject = EventTypeSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<EventTypeResponse>> getAll() async {
    final searchObject = EventTypeSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<bool> deleteEventType(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}