import 'package:ecochallenge_mobile/models/event.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class EventProvider extends BaseProvider<Event> {
  EventProvider() : super("Event");

  @override
  Event fromJson(data) {
    // TODO: implement fromJson
    return Event.fromJson(data);
  }
}
