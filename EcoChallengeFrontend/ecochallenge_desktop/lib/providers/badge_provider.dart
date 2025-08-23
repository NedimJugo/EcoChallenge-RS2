import 'dart:convert';
import 'dart:io';
import 'package:ecochallenge_desktop/models/badge.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class BadgeProvider extends BaseProvider<BadgeResponse> {
  BadgeProvider() : super("Badge");

  @override
  BadgeResponse fromJson(data) {
    return BadgeResponse.fromJson(data);
  }

  // Insert a new Badge
  Future<BadgeResponse> insertBadge(BadgeInsertRequest request, {File? imageFile}) async {
    var url = "$baseUrl/$endpoint";
    var uri = Uri.parse(url);
    
    var multipartRequest = http.MultipartRequest('POST', uri);
    
    // Add authorization header
    var headers = createHeaders();
    headers.remove('Content-Type'); // Remove JSON content type for multipart
    multipartRequest.headers.addAll(headers);
    
    // Add form fields
    multipartRequest.fields['name'] = request.name;
    if (request.description != null) {
      multipartRequest.fields['description'] = request.description!;
    }
    multipartRequest.fields['badgeTypeId'] = request.badgeTypeId.toString();
    multipartRequest.fields['criteriaTypeId'] = request.criteriaTypeId.toString();
    multipartRequest.fields['criteriaValue'] = request.criteriaValue.toString();
    multipartRequest.fields['isActive'] = request.isActive.toString();
    
    // Add image file if provided
    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'iconUrl', // This should match the backend parameter name
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      multipartRequest.files.add(multipartFile);
    }
    
    var response = await multipartRequest.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode < 299) {
      var data = jsonDecode(responseBody);
      return fromJson(data);
    } else {
      print("Error response body: $responseBody");
      throw Exception("Failed to create badge: ${response.statusCode}");
    }
  }

  // Update an existing Badge
  Future<BadgeResponse> updateBadge(int id, BadgeUpdateRequest request, {File? imageFile}) async {
    var url = "$baseUrl/$endpoint/$id";
    var uri = Uri.parse(url);
    
    var multipartRequest = http.MultipartRequest('PUT', uri);
    
    // Add authorization header
    var headers = createHeaders();
    headers.remove('Content-Type'); // Remove JSON content type for multipart
    multipartRequest.headers.addAll(headers);
    
    // Add form fields (only non-null values)
    if (request.name != null) {
      multipartRequest.fields['name'] = request.name!;
    }
    if (request.description != null) {
      multipartRequest.fields['description'] = request.description!;
    }
    if (request.badgeTypeId != null) {
      multipartRequest.fields['badgeTypeId'] = request.badgeTypeId.toString();
    }
    if (request.criteriaTypeId != null) {
      multipartRequest.fields['criteriaTypeId'] = request.criteriaTypeId.toString();
    }
    if (request.criteriaValue != null) {
      multipartRequest.fields['criteriaValue'] = request.criteriaValue.toString();
    }
    if (request.isActive != null) {
      multipartRequest.fields['isActive'] = request.isActive.toString();
    }
    
    // Add image file if provided
    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'iconUrl', // This should match the backend parameter name
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      multipartRequest.files.add(multipartFile);
    }
    
    var response = await multipartRequest.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode < 299) {
      var data = jsonDecode(responseBody);
      return fromJson(data);
    } else {
      print("Error response body: $responseBody");
      throw Exception("Failed to update badge: ${response.statusCode}");
    }
  }

  // Get all badges for dropdown usage
  Future<List<BadgeResponse>> getAllBadges() async {
    try {
      final result = await get();
      return result.items ?? [];
    } catch (e) {
      throw Exception("Failed to get badges: $e");
    }
  }

  // Delete Badge by ID
  Future<bool> deleteBadge(int id) async {
    try {
      await super.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
