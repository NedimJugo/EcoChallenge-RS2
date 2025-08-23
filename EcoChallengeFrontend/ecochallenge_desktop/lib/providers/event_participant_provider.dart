import 'package:ecochallenge_desktop/models/event_participant.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class EventParticipantProvider extends BaseProvider<EventParticipantResponse> {
  EventParticipantProvider() : super("EventParticipant");

  @override
  EventParticipantResponse fromJson(data) {
    return EventParticipantResponse.fromJson(data);
  }

  // ENHANCED: Add participant to event with better error handling
  Future<EventParticipantResponse> addParticipant(EventParticipantInsertRequest request) async {
    try {
      print('DEBUG: Adding participant with request: ${request.toJson()}');
      
      // First check if the event exists
      await _verifyEventExists(request.eventId);
      
      // Check if user is already registered
      final existingParticipation = await _checkExistingParticipation(request.eventId, request.userId);
      if (existingParticipation != null) {
        throw Exception('You are already registered for this event');
      }
      
      return await super.insert(request);
    } catch (e) {
      print('DEBUG: Error in addParticipant: $e');
      rethrow;
    }
  }

  // Helper method to verify event exists
  Future<void> _verifyEventExists(int eventId) async {
    var baseUrl = this.baseUrl;
    var url = "$baseUrl/Event/$eventId";
    
    print("DEBUG: Verifying event exists at: $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    try {
      var response = await http.get(uri, headers: headers);
      print("DEBUG: Event verification response: ${response.statusCode}");
      
      if (response.statusCode == 404) {
        throw Exception('This event no longer exists or has been cancelled');
      } else if (response.statusCode != 200) {
        throw Exception('Unable to verify event status');
      }
    } catch (e) {
      if (e.toString().contains('event no longer exists')) {
        rethrow;
      }
      print('DEBUG: Error verifying event: $e');
      // Don't block signup if we can't verify - let the backend handle it
    }
  }

  // Helper method to check existing participation
  Future<EventParticipantResponse?> _checkExistingParticipation(int eventId, int userId) async {
    try {
      final searchObject = EventParticipantSearchObject(
        eventId: eventId,
        userId: userId,
        retrieveAll: true,
      );
      
      final result = await super.get(filter: searchObject.toJson());
      return result.items?.isNotEmpty == true ? result.items!.first : null;
    } catch (e) {
      print('DEBUG: Error checking existing participation: $e');
      return null; // If we can't check, let the backend handle duplicates
    }
  }

  // Remove participant from event
  Future<bool> removeParticipant(int participantId) async {
    var baseUrl = this.baseUrl;
    var endpoint = this.endpoint;
    var url = "$baseUrl/$endpoint/$participantId";
    
    print("DELETE URL: $url");
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    try {
      var response = await http.delete(uri, headers: headers);
      print("Remove participant response status: ${response.statusCode}");
      print("Remove participant response body: ${response.body}");
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Check your credentials");
      } else if (response.statusCode == 404) {
        throw Exception("Participant not found");
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Remove participant request failed: $e");
      throw Exception("Network error: $e");
    }
  }

  // Remove participant by event and user ID (alternative method)
  Future<bool> removeParticipantByEventAndUser(int eventId, int userId) async {
    try {
      // First, find the participant record
      final searchObject = EventParticipantSearchObject(
        eventId: eventId,
        userId: userId,
        retrieveAll: true,
      );
      
      final result = await super.get(filter: searchObject.toJson());
      
      if (result.items?.isNotEmpty == true) {
        final participant = result.items!.first;
        return await removeParticipant(participant.id);
      } else {
        throw Exception("Participant not found in event");
      }
    } catch (e) {
      throw Exception("Error removing participant: $e");
    }
  }

  // Update participant status
  Future<EventParticipantResponse> updateParticipant(int participantId, EventParticipantUpdateRequest request) async {
    return await super.update(participantId, request);
  }

  // Get participants for an event
  Future<List<EventParticipantResponse>> getEventParticipants(int eventId) async {
    final searchObject = EventParticipantSearchObject(
      eventId: eventId,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  // Get events for a user (where they are participants)
  Future<List<EventParticipantResponse>> getUserParticipations(int userId) async {
    final searchObject = EventParticipantSearchObject(
      userId: userId,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }
}
