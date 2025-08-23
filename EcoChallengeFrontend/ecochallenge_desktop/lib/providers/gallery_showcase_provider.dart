import 'dart:convert';
import 'dart:io';

import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:ecochallenge_desktop/models/gallery_showcase.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;


class GalleryShowcaseProvider extends BaseProvider<GalleryShowcaseResponse> {
  GalleryShowcaseProvider() : super("GalleryShowcase");

  @override
  GalleryShowcaseResponse fromJson(data) {
    return GalleryShowcaseResponse.fromJson(data);
  }

  Future<GalleryShowcaseResponse> createWithImages(GalleryShowcaseInsertRequest request) async {
    // Prepare the multipart request
    var uri = Uri.parse('$baseUrl/GalleryShowcase');
    var multipartRequest = http.MultipartRequest('POST', uri);
    
    // Add headers
    multipartRequest.headers.addAll(super.createHeaders());
    
    // Add fields
    multipartRequest.fields['LocationId'] = request.locationId.toString();
    multipartRequest.fields['CreatedByAdminId'] = request.createdByAdminId.toString();
    if (request.requestId != null) {
      multipartRequest.fields['RequestId'] = request.requestId.toString();
    }
    if (request.eventId != null) {
      multipartRequest.fields['EventId'] = request.eventId.toString();
    }
    if (request.title != null) {
      multipartRequest.fields['Title'] = request.title!;
    }
    if (request.description != null) {
      multipartRequest.fields['Description'] = request.description!;
    }
    multipartRequest.fields['IsFeatured'] = request.isFeatured.toString();

    // Add files
    multipartRequest.files.add(
      await http.MultipartFile.fromPath(
        'BeforeImage',
        request.beforeImage.path,
      ),
    );
    multipartRequest.files.add(
      await http.MultipartFile.fromPath(
        'AfterImage',
        request.afterImage.path,
      ),
    );

    // Send the request
    var streamedResponse = await multipartRequest.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (super.isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to create gallery showcase: ${response.body}");
    }
  }

 Future<GalleryShowcaseResponse> updateWithImages(
  int id,
  GalleryShowcaseUpdateRequest request, {
  File? beforeImage,
  File? afterImage,
}) async {
  // Prepare the multipart request
  var uri = Uri.parse('$baseUrl/GalleryShowcase/$id');
  var multipartRequest = http.MultipartRequest('PUT', uri);
  
  // Add headers
  multipartRequest.headers.addAll(super.createHeaders());
  
  // Map fields to match C# model naming conventions
  if (request.requestId != null) {
    multipartRequest.fields['RequestId'] = request.requestId.toString();
  }
  if (request.eventId != null) {
    multipartRequest.fields['EventId'] = request.eventId.toString();
  }
  if (request.locationId != null) {
    multipartRequest.fields['LocationId'] = request.locationId.toString();
  }
  if (request.createdByAdminId != null) {
    multipartRequest.fields['CreatedByAdminId'] = request.createdByAdminId.toString();
  }
  if (request.title != null) {
    multipartRequest.fields['Title'] = request.title!;
  }
  if (request.description != null) {
    multipartRequest.fields['Description'] = request.description!;
  }
  if (request.isFeatured != null) {
    multipartRequest.fields['IsFeatured'] = request.isFeatured.toString();
  }
  if (request.isApproved != null) {
    multipartRequest.fields['IsApproved'] = request.isApproved.toString();
  }
  if (request.isReported != null) {
    multipartRequest.fields['IsReported'] = request.isReported.toString();
  }

  // Add files if provided
  if (beforeImage != null) {
    multipartRequest.files.add(
      await http.MultipartFile.fromPath(
        'BeforeImage',
        beforeImage.path,
      ),
    );
  }
  if (afterImage != null) {
    multipartRequest.files.add(
      await http.MultipartFile.fromPath(
        'AfterImage',
        afterImage.path,
      ),
    );
  }

  // Send the request
  var streamedResponse = await multipartRequest.send();
  var response = await http.Response.fromStream(streamedResponse);

  print('Response status: ${response.statusCode}'); // Debug logging
  print('Response body: ${response.body}'); // Debug logging

  if (super.isValidResponse(response)) {
    var data = jsonDecode(response.body);
    return fromJson(data);
  } else {
    throw Exception("Failed to update gallery showcase: ${response.statusCode} - ${response.body}");
  }
}
}