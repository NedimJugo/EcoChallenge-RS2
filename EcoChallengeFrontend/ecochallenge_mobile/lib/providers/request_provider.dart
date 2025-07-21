import 'package:ecochallenge_mobile/models/request.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class RequestProvider extends BaseProvider<Request> {
  RequestProvider() : super("Request");

  @override
  Request fromJson(data) {
    // TODO: implement fromJson
    return Request.fromJson(data);
  }
}
