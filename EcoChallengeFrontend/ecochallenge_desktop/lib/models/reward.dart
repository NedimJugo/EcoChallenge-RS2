
enum RewardStatus {
  pending,
  approved,
  rejected,
  paid
}

extension RewardStatusExtension on RewardStatus {
  String get displayName {
    switch (this) {
      case RewardStatus.pending:
        return 'Pending';
      case RewardStatus.approved:
        return 'Approved';
      case RewardStatus.rejected:
        return 'Rejected';
      case RewardStatus.paid:
        return 'Paid';
    }
  }

  static RewardStatus fromInt(int value) {
    return RewardStatus.values[value];
  }
}

// Reward Response Model
class RewardResponse {
  final int id;
  final int userId;
  final int? requestId;
  final int? eventId;
  final int? donationId;
  final int rewardTypeId;
  final int pointsAmount;
  final double moneyAmount;
  final String currency;
  final int? badgeId;
  final String? reason;
  final RewardStatus status;
  final int? approvedByAdminId;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final String? userName;
  final String? approvedByAdminName;

  RewardResponse({
    required this.id,
    required this.userId,
    this.requestId,
    this.eventId,
    this.donationId,
    required this.rewardTypeId,
    required this.pointsAmount,
    required this.moneyAmount,
    required this.currency,
    this.badgeId,
    this.reason,
    required this.status,
    this.approvedByAdminId,
    required this.createdAt,
    this.approvedAt,
    this.paidAt,
    this.userName,
    this.approvedByAdminName,
  });

  factory RewardResponse.fromJson(Map<String, dynamic> json) {
    return RewardResponse(
      id: json['id'],
      userId: json['userId'],
      requestId: json['requestId'],
      eventId: json['eventId'],
      donationId: json['donationId'],
      rewardTypeId: json['rewardTypeId'],
      pointsAmount: json['pointsAmount'],
      moneyAmount: (json['moneyAmount'] as num).toDouble(),
      currency: json['currency'] ?? 'BAM',
      badgeId: json['badgeId'],
      reason: json['reason'],
      status: RewardStatusExtension.fromInt(json['status']),
      approvedByAdminId: json['approvedByAdminId'],
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      userName: json['userName'],
      approvedByAdminName: json['approvedByAdminName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'requestId': requestId,
      'eventId': eventId,
      'donationId': donationId,
      'rewardTypeId': rewardTypeId,
      'pointsAmount': pointsAmount,
      'moneyAmount': moneyAmount,
      'currency': currency,
      'badgeId': badgeId,
      'reason': reason,
      'status': status.index,
      'approvedByAdminId': approvedByAdminId,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'userName': userName,
      'approvedByAdminName': approvedByAdminName,
    };
  }
}

// Reward Insert Request Model
class RewardInsertRequest {
  final int userId;
  final int? requestId;
  final int? eventId;
  final int? donationId;
  final int rewardTypeId;
  final int pointsAmount;
  final double moneyAmount;
  final String currency;
  final int? badgeId;
  final String? reason;
  final RewardStatus status;
  final int? approvedByAdminId;
  final DateTime? approvedAt;
  final DateTime? paidAt;

  RewardInsertRequest({
    required this.userId,
    this.requestId,
    this.eventId,
    this.donationId,
    required this.rewardTypeId,
    required this.pointsAmount,
    this.moneyAmount = 0.0,
    this.currency = 'BAM',
    this.badgeId,
    this.reason,
    this.status = RewardStatus.pending,
    this.approvedByAdminId,
    this.approvedAt,
    this.paidAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'requestId': requestId,
      'eventId': eventId,
      'donationId': donationId,
      'rewardTypeId': rewardTypeId,
      'pointsAmount': pointsAmount,
      'moneyAmount': moneyAmount,
      'currency': currency,
      'badgeId': badgeId,
      'reason': reason,
      'status': status.index,
      'approvedByAdminId': approvedByAdminId,
      'approvedAt': approvedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}

// Reward Update Request Model
class RewardUpdateRequest {
  final int id;
  final int? userId;
  final int? requestId;
  final int? eventId;
  final int? donationId;
  final int? rewardTypeId;
  final int? pointsAmount;
  final double? moneyAmount;
  final String? currency;
  final int? badgeId;
  final String? reason;
  final RewardStatus? status;
  final int? approvedByAdminId;
  final DateTime? approvedAt;
  final DateTime? paidAt;

  RewardUpdateRequest({
    required this.id,
    this.userId,
    this.requestId,
    this.eventId,
    this.donationId,
    this.rewardTypeId,
    this.pointsAmount,
    this.moneyAmount,
    this.currency,
    this.badgeId,
    this.reason,
    this.status,
    this.approvedByAdminId,
    this.approvedAt,
    this.paidAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (userId != null) data['userId'] = userId;
    if (requestId != null) data['requestId'] = requestId;
    if (eventId != null) data['eventId'] = eventId;
    if (donationId != null) data['donationId'] = donationId;
    if (rewardTypeId != null) data['rewardTypeId'] = rewardTypeId;
    if (pointsAmount != null) data['pointsAmount'] = pointsAmount;
    if (moneyAmount != null) data['moneyAmount'] = moneyAmount;
    if (currency != null) data['currency'] = currency;
    if (badgeId != null) data['badgeId'] = badgeId;
    if (reason != null) data['reason'] = reason;
    if (status != null) data['status'] = status!.index;
    if (approvedByAdminId != null) data['approvedByAdminId'] = approvedByAdminId;
    if (approvedAt != null) data['approvedAt'] = approvedAt!.toIso8601String();
    if (paidAt != null) data['paidAt'] = paidAt!.toIso8601String();
    
    return data;
  }
}

// Reward Search Object
class RewardSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? userId;
  int? rewardTypeId;
  RewardStatus? status;
  int? approvedByAdminId;
  int? donationId;
  int? eventId;
  double? minAmount;
  double? maxAmount;

  RewardSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.userId,
    this.rewardTypeId,
    this.status,
    this.approvedByAdminId,
    this.donationId,
    this.eventId,
    this.minAmount,
    this.maxAmount,
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

    if (userId != null) data['userId'] = userId;
    if (rewardTypeId != null) data['rewardTypeId'] = rewardTypeId;
    if (status != null) data['status'] = status!.index;
    if (approvedByAdminId != null) data['approvedByAdminId'] = approvedByAdminId;
    if (donationId != null) data['donationId'] = donationId;
    if (eventId != null) data['eventId'] = eventId;
    if (minAmount != null) data['minAmount'] = minAmount;
    if (maxAmount != null) data['maxAmount'] = maxAmount;

    return data;
  }
}
