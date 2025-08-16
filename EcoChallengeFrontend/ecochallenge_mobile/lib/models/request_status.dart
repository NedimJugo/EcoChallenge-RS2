// request_status_response.dart
class RequestStatusResponse {
  final int id;
  final String name;

  RequestStatusResponse({
    required this.id,
    required this.name,
  });

  factory RequestStatusResponse.fromJson(Map<String, dynamic> json) {
    return RequestStatusResponse(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// request_status_insert_request.dart
class RequestStatusInsertRequest {
  final String name;

  RequestStatusInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// request_status_update_request.dart
class RequestStatusUpdateRequest {
  final int id;
  final String? name;

  RequestStatusUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// request_status_search_object.dart
class RequestStatusSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  RequestStatusSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'desc': desc,
      'includeTotalCount': includeTotalCount,
      'retrieveAll': retrieveAll,
    };

    if (name != null) data['name'] = name;

    return data;
  }
}