// Enum to match your backend
enum ParticipationStatus {
  pending,
  approved,
  rejected
}

extension ParticipationStatusExtension on ParticipationStatus {
  String get displayName {
    switch (this) {
      case ParticipationStatus.pending:
        return 'Pending';
      case ParticipationStatus.approved:
        return 'Approved';
      case ParticipationStatus.rejected:
        return 'Rejected';
    }
  }

  static ParticipationStatus fromInt(int value) {
    return ParticipationStatus.values[value];
  }
}

// Request Participation Response Model
class RequestParticipationResponse {
  final int id;
  final int userId;
  final int requestId;
  final String? adminNotes;
  final ParticipationStatus status;
  final int rewardPoints;
  final double rewardMoney;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final List<String>? photoUrls;

  RequestParticipationResponse({
    required this.id,
    required this.userId,
    required this.requestId,
    this.adminNotes,
    required this.status,
    required this.rewardPoints,
    required this.rewardMoney,
    required this.submittedAt,
    this.approvedAt,
    this.photoUrls,
  });

  factory RequestParticipationResponse.fromJson(Map<String, dynamic> json) {
    return RequestParticipationResponse(
      id: json['id'],
      userId: json['userId'],
      requestId: json['requestId'],
      adminNotes: json['adminNotes'],
      status: ParticipationStatusExtension.fromInt(json['status']),
      rewardPoints: json['rewardPoints'],
      rewardMoney: (json['rewardMoney'] as num).toDouble(),
      submittedAt: DateTime.parse(json['submittedAt']),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      photoUrls: json['photoUrls'] != null 
          ? List<String>.from(json['photoUrls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'requestId': requestId,
      'adminNotes': adminNotes,
      'status': status.index,
      'rewardPoints': rewardPoints,
      'rewardMoney': rewardMoney,
      'submittedAt': submittedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'photoUrls': photoUrls,
    };
  }
}

// Request Participation Insert Request Model
class RequestParticipationInsertRequest {
  final int userId;
  final int requestId;
  final String? adminNotes;
  final List<String>? photoUrls;

  RequestParticipationInsertRequest({
    required this.userId,
    required this.requestId,
    this.adminNotes,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'requestId': requestId,
      'adminNotes': adminNotes,
      'photoUrls': photoUrls,
    };
  }
}

// Request Participation Update Request Model
class RequestParticipationUpdateRequest {
  final int id;
  final ParticipationStatus? status;
  final String? adminNotes;
  final int? rewardPoints;
  final double? rewardMoney;
  final DateTime? approvedAt;
  final List<String>? photoUrls;

  RequestParticipationUpdateRequest({
    required this.id,
    this.status,
    this.adminNotes,
    this.rewardPoints,
    this.rewardMoney,
    this.approvedAt,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (status != null) data['status'] = status!.index;
    if (adminNotes != null) data['adminNotes'] = adminNotes;
    if (rewardPoints != null) data['rewardPoints'] = rewardPoints;
    if (rewardMoney != null) data['rewardMoney'] = rewardMoney;
    if (approvedAt != null) data['approvedAt'] = approvedAt!.toIso8601String();
    if (photoUrls != null) data['photoUrls'] = photoUrls;
    
    return data;
  }
}

// Request Participation Search Object
class RequestParticipationSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? userId;
  int? requestId;
  ParticipationStatus? status;

  RequestParticipationSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.userId,
    this.requestId,
    this.status,
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
    if (requestId != null) data['requestId'] = requestId;
    if (status != null) data['status'] = status!.index;

    return data;
  }
}
