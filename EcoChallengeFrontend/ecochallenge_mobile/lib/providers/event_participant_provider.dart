
import 'package:ecochallenge_mobile/models/event_participant.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';


class EventParticipantProvider extends BaseProvider<EventParticipantResponse> {
  EventParticipantProvider() : super("EventParticipant");

  @override
  EventParticipantResponse fromJson(data) {
    return EventParticipantResponse.fromJson(data);
  }
}
