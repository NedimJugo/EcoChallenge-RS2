// criteria_type_response.dart
class CriteriaTypeResponse {
  final int id;
  final String name;

  CriteriaTypeResponse({
    required this.id,
    required this.name,
  });

  factory CriteriaTypeResponse.fromJson(Map<String, dynamic> json) {
    return CriteriaTypeResponse(
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

// criteria_type_insert_request.dart
class CriteriaTypeInsertRequest {
  final String name;

  CriteriaTypeInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// criteria_type_update_request.dart
class CriteriaTypeUpdateRequest {
  final int id;
  final String? name;

  CriteriaTypeUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// criteria_type_search_object.dart
class CriteriaTypeSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  CriteriaTypeSearchObject({
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