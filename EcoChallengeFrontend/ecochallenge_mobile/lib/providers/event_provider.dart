import 'package:ecochallenge_mobile/models/event.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

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
}
