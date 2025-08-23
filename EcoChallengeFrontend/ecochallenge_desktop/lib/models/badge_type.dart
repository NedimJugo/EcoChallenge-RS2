// badge_type_response.dart
class BadgeTypeResponse {
  final int id;
  final String name;

  BadgeTypeResponse({
    required this.id,
    required this.name,
  });

  factory BadgeTypeResponse.fromJson(Map<String, dynamic> json) {
    return BadgeTypeResponse(
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

// badge_type_insert_request.dart
class BadgeTypeInsertRequest {
  final String name;

  BadgeTypeInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// badge_type_update_request.dart
class BadgeTypeUpdateRequest {
  final int id;
  final String? name;

  BadgeTypeUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// badge_type_search_object.dart
class BadgeTypeSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  BadgeTypeSearchObject({
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