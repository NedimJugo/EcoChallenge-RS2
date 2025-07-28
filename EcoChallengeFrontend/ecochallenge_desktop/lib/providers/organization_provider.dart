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

  Future<void> insertOrganization(OrganizationInsertRequest request) async {
  final uri = Uri.parse('${BaseProvider.baseUrl}Organization'); // or with slash logic if needed


  final multipartRequest = http.MultipartRequest('POST', uri);

  // Add all the fields
  multipartRequest.fields['name'] = request.name;
  if (request.description != null) multipartRequest.fields['description'] = request.description!;
  if (request.website != null) multipartRequest.fields['website'] = request.website!;
  if (request.contactEmail != null) multipartRequest.fields['contactEmail'] = request.contactEmail!;
  if (request.contactPhone != null) multipartRequest.fields['contactPhone'] = request.contactPhone!;
  if (request.category != null) multipartRequest.fields['category'] = request.category!;
  multipartRequest.fields['isVerified'] = request.isVerified.toString();
  multipartRequest.fields['isActive'] = request.isActive.toString();

  // Add logo if present
  if (request.logoImage != null) {
    multipartRequest.files.add(await http.MultipartFile.fromPath(
      'logoImage',
      request.logoImage!.path,
    ));
  }

  // ✅ Add headers with authorization
  multipartRequest.headers.addAll(createHeaders());

  // Send request
  final streamedResponse = await multipartRequest.send();
  final responseBody = await streamedResponse.stream.bytesToString();

  print("Response Code: ${streamedResponse.statusCode}");
  print("Backend Error: $responseBody");

  if (streamedResponse.statusCode >= 400) {
    throw Exception('Failed to insert organization: $responseBody');
  }
}



Future<void> updateOrganization(int id, OrganizationUpdateRequest request) async {
  var uri = Uri.parse('$baseUrl/Organization/$id');
  var multipartRequest = http.MultipartRequest('PUT', uri);

  // Add fields
  if (request.name != null) multipartRequest.fields['name'] = request.name!;
  if (request.description != null) multipartRequest.fields['description'] = request.description!;
  if (request.website != null) multipartRequest.fields['website'] = request.website!;
  if (request.contactEmail != null) multipartRequest.fields['contactEmail'] = request.contactEmail!;
  if (request.contactPhone != null) multipartRequest.fields['contactPhone'] = request.contactPhone!;
  if (request.category != null) multipartRequest.fields['category'] = request.category!;
  if (request.isVerified != null) multipartRequest.fields['isVerified'] = request.isVerified.toString();
  if (request.isActive != null) multipartRequest.fields['isActive'] = request.isActive.toString();

  // Add logo if provided
  if (request.logoImage != null) {
    multipartRequest.files.add(await http.MultipartFile.fromPath(
      'logoImage', // Key must match backend
      request.logoImage!.path,
    ));
  }

  var response = await multipartRequest.send();

  if (response.statusCode != 200) {
    final errorText = await response.stream.bytesToString();
    throw Exception('Failed to update organization: $errorText');
  }
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
