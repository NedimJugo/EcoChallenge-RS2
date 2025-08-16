// donation_status_provider.dart
import 'dart:convert';

import 'package:ecochallenge_mobile/models/donation_status.dart';
import 'package:http/http.dart' as http;
import '../providers/base_provider.dart';

class DonationStatusProvider extends BaseProvider<DonationStatusResponse> {
  DonationStatusProvider() : super("DonationStatus");

  @override
  DonationStatusResponse fromJson(data) {
    return DonationStatusResponse.fromJson(data);
  }

  Future<DonationStatusResponse> insertDonationStatus(DonationStatusInsertRequest request) async {
    return await super.insert(request);
  }

  Future<DonationStatusResponse> updateDonationStatus(int id, DonationStatusUpdateRequest request) async {
    return await super.update(id, request);
  }

  Future<List<DonationStatusResponse>> getByName(String name) async {
    final searchObject = DonationStatusSearchObject(
      name: name,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<List<DonationStatusResponse>> getAll() async {
    final searchObject = DonationStatusSearchObject(
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  Future<DonationStatusResponse?> getById(int id) async {
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

  Future<bool> deleteDonationStatus(int id) async {
    var url = "${super.baseUrl}/${super.endpoint}/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    
    var response = await http.delete(uri, headers: headers);
    
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}