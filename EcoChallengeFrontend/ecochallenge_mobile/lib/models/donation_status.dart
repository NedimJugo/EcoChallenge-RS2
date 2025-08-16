// donation_status_response.dart
class DonationStatusResponse {
  final int id;
  final String name;

  DonationStatusResponse({
    required this.id,
    required this.name,
  });

  factory DonationStatusResponse.fromJson(Map<String, dynamic> json) {
    return DonationStatusResponse(
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

// donation_status_insert_request.dart
class DonationStatusInsertRequest {
  final String name;

  DonationStatusInsertRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

// donation_status_update_request.dart
class DonationStatusUpdateRequest {
  final int id;
  final String? name;

  DonationStatusUpdateRequest({
    required this.id,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    return data;
  }
}

// donation_status_search_object.dart
class DonationStatusSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? name;

  DonationStatusSearchObject({
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