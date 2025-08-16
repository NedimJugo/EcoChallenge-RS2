// entity_type_response.dart
class EntityTypeResponse {
  final int id;
  final String name;

  EntityTypeResponse({
    required this.id,
    required this.name,
  });

  factory EntityTypeResponse.fromJson(Map<String, dynamic> json) {
    return EntityTypeResponse(
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

// entity_type_insert_request.dart
class EntityTypeInsertRequest {
  final String name;

  EntityTypeInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// entity_type_update_request.dart
class EntityTypeUpdateRequest {
  final int id;
  final String? name;

  EntityTypeUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// entity_type_search_object.dart
class EntityTypeSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  EntityTypeSearchObject({
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