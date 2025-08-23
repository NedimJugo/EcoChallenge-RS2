import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class EventProvider extends BaseProvider<EventResponse> {
  EventProvider() : super("Event");

  @override
  EventResponse fromJson(data) {
    return EventResponse.fromJson(data);
  }

  // Method to insert event without files (JSON only)
  Future<EventResponse> insertEvent(EventInsertRequest event) async {
    return await super.insert(event);
  }

  // Delete event method
  Future<bool> deleteEvent(int eventId) async {
    var baseUrl = this.baseUrl;
    var endpoint = this.endpoint;
    var url = "$baseUrl/$endpoint/$eventId";
    
    print("DELETE URL: $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    try {
      var response = await http.delete(uri, headers: headers);
      print("Delete response status: ${response.statusCode}");
      print("Delete response body: ${response.body}");
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Check your credentials");
      } else if (response.statusCode == 404) {
        throw Exception("Event not found");
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Delete request failed: $e");
      throw Exception("Network error: $e");
    }
  }

  // Update event method (if you need to update events)
  Future<EventResponse> updateEvent(int eventId, EventUpdateRequest request) async {
    return await super.update(eventId, request);
  }

  // Get events by creator
  Future<List<EventResponse>> getEventsByCreator(int creatorUserId) async {
    final searchObject = EventSearchObject(
      creatorUserId: creatorUserId,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }
}