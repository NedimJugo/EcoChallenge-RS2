

import 'dart:convert';

import 'package:ecochallenge_desktop/models/request_participation.dart';
import 'package:ecochallenge_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RequestParticipationProvider extends BaseProvider<RequestParticipationResponse> {
  RequestParticipationProvider() : super("RequestParticipation");

  @override
  RequestParticipationResponse fromJson(data) {
    return RequestParticipationResponse.fromJson(data);
  }

  // Method to insert request participation without files (JSON only)
  Future<RequestParticipationResponse> insertRequestParticipation(RequestParticipationInsertRequest requestParticipation) async {
    return await super.insert(requestParticipation);
  }

  // Method to update request participation with multipart form data (for payment approval)
  Future<RequestParticipationResponse> updateWithFormData(
    int id,
    RequestParticipationUpdateRequest request,
  ) async {
    // Prepare the multipart request
    var uri = Uri.parse('$baseUrl/RequestParticipation/$id');
    var multipartRequest = http.MultipartRequest('PUT', uri);
        
    // Add headers
    multipartRequest.headers.addAll(super.createHeaders());
        
    // Add fields
    multipartRequest.fields['id'] = id.toString();
    
    if (request.status != null) {
      multipartRequest.fields['status'] = request.status!.index.toString();
    }
    if (request.adminNotes != null) {
      multipartRequest.fields['adminNotes'] = request.adminNotes!;
    }
    if (request.rewardPoints != null) {
      multipartRequest.fields['rewardPoints'] = request.rewardPoints.toString();
    }
    if (request.rewardMoney != null) {
      multipartRequest.fields['rewardMoney'] = request.rewardMoney.toString();
    }
    if (request.approvedAt != null) {
      multipartRequest.fields['approvedAt'] = request.approvedAt!.toIso8601String();
    }
    if (request.cardHolderName != null) {
      multipartRequest.fields['cardHolderName'] = request.cardHolderName!;
    }
    if (request.bankName != null) {
      multipartRequest.fields['bankName'] = request.bankName!;
    }
    if (request.transactionNumber != null) {
      multipartRequest.fields['transactionNumber'] = request.transactionNumber!;
    }
    if (request.rejectionReason != null) {
      multipartRequest.fields['rejectionReason'] = request.rejectionReason!;
    }

    // Send the request
    var streamedResponse = await multipartRequest.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (super.isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to update request participation: ${response.body}");
    }
  }
}