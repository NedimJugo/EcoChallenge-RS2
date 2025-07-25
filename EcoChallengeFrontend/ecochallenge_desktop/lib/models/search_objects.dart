class BaseSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;

  BaseSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'desc': desc,
      'includeTotalCount': includeTotalCount,
      'retrieveAll': retrieveAll,
    };
  }
}

class UserSearchObject extends BaseSearchObject {
  String? text;
  int? userTypeId;
  bool? isActive;
  String? country;
  String? city;

  UserSearchObject({
    this.text,
    this.userTypeId,
    this.isActive,
    this.country,
    this.city,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (text != null) json['text'] = text;
    if (userTypeId != null) json['userTypeId'] = userTypeId;
    if (isActive != null) json['isActive'] = isActive;
    if (country != null) json['country'] = country;
    if (city != null) json['city'] = city;
    return json;
  }
}

class UserTypeSearchObject extends BaseSearchObject {
  String? name;

  UserTypeSearchObject({
    this.name,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null) json['name'] = name;
    return json;
  }
}


class BadgeSearchObject extends BaseSearchObject {
  String? name;
  int? badgeTypeId;

  BadgeSearchObject({
    this.name,
    this.badgeTypeId,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null) json['name'] = name;
    if (badgeTypeId != null) json['badgeTypeId'] = badgeTypeId;
    return json;
  }
}

class LocationSearchObject extends BaseSearchObject {
  String? name;
  String? city;
  String? country;
  int? locationType; // Using int to match enum index

  LocationSearchObject({
    this.name,
    this.city,
    this.country,
    this.locationType,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null) json['name'] = name;
    if (city != null) json['city'] = city;
    if (country != null) json['country'] = country;
    if (locationType != null) json['locationType'] = locationType;
    return json;
  }
}


class UserBadgeSearchObject extends BaseSearchObject {
  int? userId;
  int? badgeId;
  DateTime? fromDate;
  DateTime? toDate;

  UserBadgeSearchObject({
    this.userId,
    this.badgeId,
    this.fromDate,
    this.toDate,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (userId != null) json['userId'] = userId;
    if (badgeId != null) json['badgeId'] = badgeId;
    if (fromDate != null) json['fromDate'] = fromDate!.toIso8601String();
    if (toDate != null) json['toDate'] = toDate!.toIso8601String();
    return json;
  }
}

class WasteTypeSearchObject extends BaseSearchObject {
  String? name;

  WasteTypeSearchObject({
    this.name,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null) json['name'] = name;
    return json;
  }
}

class OrganizationSearchObject extends BaseSearchObject {
  String? text;
  bool? isVerified;
  bool? isActive;
  String? category;

  OrganizationSearchObject({
    this.text,
    this.isVerified,
    this.isActive,
    this.category,
    int? page = 0,
    int? pageSize = 20,
    String sortBy = "Id",
    bool desc = false,
    bool includeTotalCount = true,
    bool retrieveAll = false,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          desc: desc,
          includeTotalCount: includeTotalCount,
          retrieveAll: retrieveAll,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (text != null) json['text'] = text;
    if (isVerified != null) json['isVerified'] = isVerified;
    if (isActive != null) json['isActive'] = isActive;
    if (category != null) json['category'] = category;
    return json;
  }
}