// UserBadge Response model
import 'package:ecochallenge_desktop/models/search_objects.dart';

class UserBadgeResponse {
  final int id;
  final int userId;
  final int badgeId;
  final DateTime earnedAt;

  UserBadgeResponse({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
  });

  factory UserBadgeResponse.fromJson(Map<String, dynamic> json) {
    return UserBadgeResponse(
      id: json['id'],
      userId: json['userId'],
      badgeId: json['badgeId'],
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'badgeId': badgeId,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}

// UserBadge Insert Request model
class UserBadgeInsertRequest {
  final int userId;
  final int badgeId;
  final DateTime? earnedAt;

  UserBadgeInsertRequest({
    required this.userId,
    required this.badgeId,
    this.earnedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }
}

// UserBadge Update Request model
class UserBadgeUpdateRequest {
  final int? userId;
  final int? badgeId;
  final DateTime? earnedAt;

  UserBadgeUpdateRequest({
    this.userId,
    this.badgeId,
    this.earnedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (userId != null) data['userId'] = userId;
    if (badgeId != null) data['badgeId'] = badgeId;
    if (earnedAt != null) data['earnedAt'] = earnedAt!.toIso8601String();
    
    return data;
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