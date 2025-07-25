// UserBadge Response model
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
