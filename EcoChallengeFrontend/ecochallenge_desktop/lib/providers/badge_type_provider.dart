// badge_type_provider.dart
import 'dart:convert';
import 'package:ecochallenge_desktop/models/badge_type.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class BadgeTypeProvider extends BaseProvider<BadgeTypeResponse> {
  BadgeTypeProvider() : super("BadgeType");

  @override
  BadgeTypeResponse fromJson(data) {
    return BadgeTypeResponse.fromJson(data);
  }

  Future<BadgeTypeResponse> insertBadgeType(BadgeTypeInsertRequest request) async {
    return await super.insert(request);
  }

  Future<BadgeTypeResponse> updateBadgeType(int id, BadgeTypeUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<BadgeTypeResponse>> getByName(String name) async {
    final searchObject = BadgeTypeSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<BadgeTypeResponse>> getAll() async {
    final searchObject = BadgeTypeSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }


  Future<bool> deleteBadgeType(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}