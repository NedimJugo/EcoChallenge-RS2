import 'package:ecochallenge_mobile/models/request_participation.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class RequestParticipationProvider extends BaseProvider<RequestParticipationResponse> {
  RequestParticipationProvider() : super("RequestParticipation");

  @override
  RequestParticipationResponse fromJson(data) {
    return RequestParticipationResponse.fromJson(data);
  }

  // Method to insert request participation without files (JSON only)
  Future<RequestParticipationResponse> insertRequestParticipation(RequestParticipationInsertRequest requestParticipation) async {
    return await super.insert(requestParticipation);
  }
}