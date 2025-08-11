
import 'dart:convert';
import 'package:ecochallenge_mobile/models/gallery_reaction.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class GalleryReactionProvider extends BaseProvider<GalleryReactionResponse> {
  GalleryReactionProvider() : super("GalleryReaction");

  @override
  GalleryReactionResponse fromJson(data) {
    return GalleryReactionResponse.fromJson(data);
  }

  Future<GalleryReactionResponse> addReaction(GalleryReactionInsertRequest request) async {
    return await insert(request);
  }

  Future<GalleryReactionResponse> updateReaction(GalleryReactionUpdateRequest request) async {
    return await updateReactionCustom(request);
  }

  Future<GalleryReactionResponse> updateReactionCustom(GalleryReactionUpdateRequest request) async {
  const String baseUrl = "http://10.0.2.2:5087/api";
  var url = "$baseUrl/GalleryReaction/${request.id}";
  
  print("Updating reaction to: ${request.reactionType}");
  
  var uri = Uri.parse(url);
  var headers = createHeaders();
  headers['Content-Type'] = 'application/json';
  headers['Accept'] = 'application/json';
  
  var requestBody = {
    "id": request.id,   // <-- add this
    "reactionType": _getReactionTypeValue(request.reactionType),
  };
  
  var jsonRequest = jsonEncode(requestBody);
  print("Request body: $jsonRequest");
  
  var response = await http.put(uri, headers: headers, body: jsonRequest);
  
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.body}");
  
  if (isValidResponse(response)) {
    var data = jsonDecode(response.body);
    return fromJson(data);
  } else {
    print("Error response body: ${response.body}");
    throw Exception("Failed to update gallery reaction: ${response.body}");
  }
}

  // Helper method to convert ReactionType enum to integer
  int _getReactionTypeValue(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.like:
        return 0;
      case ReactionType.dislike:
        return 1;
      case ReactionType.report:
        return 2;
    }
  }

  Future<bool> delete(int id) async {
  const String baseUrl = "http://10.0.2.2:5087/api";
  var url = "$baseUrl/GalleryReaction/$id";
  
  print("DELETE URL (Gallery Reaction): $url");
  var uri = Uri.parse(url);
  var headers = createHeaders();
  
  var response = await http.delete(uri, headers: headers);
  
  print("DELETE Response status (Gallery Reaction): ${response.statusCode}");
  print("DELETE Response body (Gallery Reaction): ${response.body}");
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return true;
  } else {
    print("DELETE Error response body (Gallery Reaction): ${response.body}");
    throw Exception("Failed to delete gallery reaction: ${response.body}");
  }
}
}
