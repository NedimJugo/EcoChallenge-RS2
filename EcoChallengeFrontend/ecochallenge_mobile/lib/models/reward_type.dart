// reward_type_response.dart
class RewardTypeResponse {
  final int id;
  final String name;

  RewardTypeResponse({
    required this.id,
    required this.name,
  });

  factory RewardTypeResponse.fromJson(Map<String, dynamic> json) {
    return RewardTypeResponse(
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

// reward_type_insert_request.dart
class RewardTypeInsertRequest {
  final String name;

  RewardTypeInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// reward_type_update_request.dart
class RewardTypeUpdateRequest {
  final int id;
  final String? name;

  RewardTypeUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// reward_type_search_object.dart
class RewardTypeSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  RewardTypeSearchObject({
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