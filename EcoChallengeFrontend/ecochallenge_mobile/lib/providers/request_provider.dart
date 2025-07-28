import 'package:ecochallenge_mobile/models/request.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class RequestProvider extends BaseProvider<RequestResponse> {
  RequestProvider() : super("Request");

  @override
  RequestResponse fromJson(data) {
    return RequestResponse.fromJson(data);
  }



  // Method to insert request without files (JSON only)
  Future<RequestResponse> insertRequest(RequestInsertRequest request) async {
    return await super.insert(request);
  }
}
