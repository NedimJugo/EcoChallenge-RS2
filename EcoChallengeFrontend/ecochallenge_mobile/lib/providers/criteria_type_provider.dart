import 'dart:convert';

import 'package:ecochallenge_mobile/models/criteria_type.dart';
import 'package:http/http.dart' as http;

import '../providers/base_provider.dart';

class CriteriaTypeProvider extends BaseProvider<CriteriaTypeResponse> {
  CriteriaTypeProvider() : super("CriteriaType");

  @override
  CriteriaTypeResponse fromJson(data) {
    return CriteriaTypeResponse.fromJson(data);
  }

  // Insert a new CriteriaType
  Future<CriteriaTypeResponse> insertCriteriaType(CriteriaTypeInsertRequest request) async {
    return await super.insert(request);
  }

  // Update an existing CriteriaType
  Future<CriteriaTypeResponse> updateCriteriaType(int id, CriteriaTypeUpdateRequest request) async {
    return await super.update(id, request);
  }

  // Get CriteriaTypes by name
  Future<List<CriteriaTypeResponse>> getByName(String name) async {
    final searchObject = CriteriaTypeSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  // Get all CriteriaTypes
  Future<List<CriteriaTypeResponse>> getAll() async {
    final searchObject = CriteriaTypeSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  // Get single CriteriaType by ID
  Future<CriteriaTypeResponse?> getById(int id) async {
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

  // Delete CriteriaType by ID
  Future<bool> deleteCriteriaType(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}