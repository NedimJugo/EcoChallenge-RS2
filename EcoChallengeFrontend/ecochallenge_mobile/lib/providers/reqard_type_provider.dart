// reward_type_provider.dart
import 'dart:convert';

import 'package:ecochallenge_mobile/models/reward_type.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class RewardTypeProvider extends BaseProvider<RewardTypeResponse> {
  RewardTypeProvider() : super("RewardType");

  @override
  RewardTypeResponse fromJson(data) {
    return RewardTypeResponse.fromJson(data);
  }

  Future<RewardTypeResponse> insertRewardType(RewardTypeInsertRequest request) async {
    return await super.insert(request);
  }

  Future<RewardTypeResponse> updateRewardType(int id, RewardTypeUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<RewardTypeResponse>> getByName(String name) async {
    final searchObject = RewardTypeSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<RewardTypeResponse>> getAll() async {
    final searchObject = RewardTypeSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<RewardTypeResponse?> getById(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.get(uri, headers: headers);
    
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    }
    return null;
  }

  Future<bool> deleteRewardType(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}