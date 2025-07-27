
import 'package:ecochallenge_desktop/models/request.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';

class RequestProvider extends BaseProvider<RequestResponse> {
  RequestProvider() : super("Request");

  @override
  RequestResponse fromJson(data) {
    return RequestResponse.fromJson(data);
  }

  
}
