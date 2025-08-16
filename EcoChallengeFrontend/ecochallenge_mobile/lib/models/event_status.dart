// event_status_response.dart
class EventStatusResponse {
  final int id;
  final String name;

  EventStatusResponse({
    required this.id,
    required this.name,
  });

  factory EventStatusResponse.fromJson(Map<String, dynamic> json) {
    return EventStatusResponse(
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

// event_status_insert_request.dart
class EventStatusInsertRequest {
  final String name;

  EventStatusInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// event_status_update_request.dart
class EventStatusUpdateRequest {
  final int id;
  final String? name;

  EventStatusUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// event_status_search_object.dart
class EventStatusSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  EventStatusSearchObject({
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