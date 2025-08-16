// entity_type_provider.dart
import 'dart:convert';

import 'package:ecochallenge_mobile/models/entity_type.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class EntityTypeProvider extends BaseProvider<EntityTypeResponse> {
  EntityTypeProvider() : super("EntityType");

  @override
  EntityTypeResponse fromJson(data) {
    return EntityTypeResponse.fromJson(data);
  }

  Future<EntityTypeResponse> insertEntityType(EntityTypeInsertRequest request) async {
    return await super.insert(request);
  }

  Future<EntityTypeResponse> updateEntityType(int id, EntityTypeUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<EntityTypeResponse>> getByName(String name) async {
    final searchObject = EntityTypeSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<EntityTypeResponse>> getAll() async {
    final searchObject = EntityTypeSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<EntityTypeResponse?> getById(int id) async {
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

  Future<bool> deleteEntityType(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}