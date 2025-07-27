import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:ecochallenge_desktop/models/search_result.dart';

class EventProvider extends BaseProvider<EventResponse> {
  EventProvider() : super("Event");

  @override
  EventResponse fromJson(data) {
    return EventResponse.fromJson(data);
  }

  
}
