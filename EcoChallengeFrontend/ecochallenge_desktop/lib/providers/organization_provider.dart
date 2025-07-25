import 'dart:convert';
import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:ecochallenge_desktop/models/organization.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;


class OrganizationProvider extends BaseProvider<OrganizationResponse> {
  OrganizationProvider() : super("Organization");

  @override
  OrganizationResponse fromJson(data) {
    return OrganizationResponse.fromJson(data);
  }
  // Add method to get all organizations for dropdown usage
  Future<List<OrganizationResponse>> getAllOrganizations() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      throw Exception("Failed to get organizations: $e");
    }
  }
}
