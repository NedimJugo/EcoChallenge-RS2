
// Enums to match your backend
enum UrgencyLevel {
  low,
  medium,
  high,
  critical
}

enum EstimatedAmount {
  small,
  medium,
  large,
  huge
}

extension UrgencyLevelExtension on UrgencyLevel {
  String get displayName {
    switch (this) {
      case UrgencyLevel.low:
        return 'Low';
      case UrgencyLevel.medium:
        return 'Medium';
      case UrgencyLevel.high:
        return 'High';
      case UrgencyLevel.critical:
        return 'Critical';
    }
  }

  static UrgencyLevel fromInt(int value) {
    return UrgencyLevel.values[value];
  }
}

extension EstimatedAmountExtension on EstimatedAmount {
  String get displayName {
    switch (this) {
      case EstimatedAmount.small:
        return 'Small';
      case EstimatedAmount.medium:
        return 'Medium';
      case EstimatedAmount.large:
        return 'Large';
      case EstimatedAmount.huge:
        return 'Huge';
    }
  }

  static EstimatedAmount fromInt(int value) {
    return EstimatedAmount.values[value];
  }
}

// Request Response Model
class RequestResponse {
  final int id;
  final int userId;
  final int locationId;
  final String? title;
  final String? description;
  final List<String>? photoUrls;
  final int? estimatedCleanupTime;
  final UrgencyLevel urgencyLevel;
  final int wasteTypeId;
  final EstimatedAmount estimatedAmount;
  final DateTime? proposedDate;
  final String? proposedTime; // TimeSpan as string
  final int statusId;
  final String? adminNotes;
  final String? rejectionReason;
  final int suggestedRewardPoints;
  final double suggestedRewardMoney;
  final int actualRewardPoints;
  final double actualRewardMoney;
  final String? aiAnalysisResult;
  final String? completionImageUrl;
  final String? completionNotes;
  final int? assignedAdminId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;

  RequestResponse({
    required this.id,
    required this.userId,
    required this.locationId,
    this.title,
    this.description,
    this.photoUrls,
    this.estimatedCleanupTime,
    required this.urgencyLevel,
    required this.wasteTypeId,
    required this.estimatedAmount,
    this.proposedDate,
    this.proposedTime,
    required this.statusId,
    this.adminNotes,
    this.rejectionReason,
    required this.suggestedRewardPoints,
    required this.suggestedRewardMoney,
    required this.actualRewardPoints,
    required this.actualRewardMoney,
    this.aiAnalysisResult,
    this.completionImageUrl,
    this.completionNotes,
    this.assignedAdminId,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.completedAt,
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(
      id: json['id'],
      userId: json['userId'],
      locationId: json['locationId'],
      title: json['title'],
      description: json['description'],
      photoUrls: json['photoUrls'] != null 
          ? List<String>.from(json['photoUrls'])
          : null,
      estimatedCleanupTime: json['estimatedCleanupTime'],
      urgencyLevel: UrgencyLevelExtension.fromInt(json['urgencyLevel']),
      wasteTypeId: json['wasteTypeId'],
      estimatedAmount: EstimatedAmountExtension.fromInt(json['estimatedAmount']),
      proposedDate: json['proposedDate'] != null ? DateTime.parse(json['proposedDate']) : null,
      proposedTime: json['proposedTime'],
      statusId: json['statusId'],
      adminNotes: json['adminNotes'],
      rejectionReason: json['rejectionReason'],
      suggestedRewardPoints: json['suggestedRewardPoints'],
      suggestedRewardMoney: (json['suggestedRewardMoney'] as num).toDouble(),
      actualRewardPoints: json['actualRewardPoints'],
      actualRewardMoney: (json['actualRewardMoney'] as num).toDouble(),
      aiAnalysisResult: json['aiAnalysisResult'],
      completionImageUrl: json['completionImageUrl'],
      completionNotes: json['completionNotes'],
      assignedAdminId: json['assignedAdminId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'locationId': locationId,
      'title': title,
      'description': description,
      'photoUrls': photoUrls,
      'estimatedCleanupTime': estimatedCleanupTime,
      'urgencyLevel': urgencyLevel.index,
      'wasteTypeId': wasteTypeId,
      'estimatedAmount': estimatedAmount.index,
      'proposedDate': proposedDate?.toIso8601String(),
      'proposedTime': proposedTime,
      'statusId': statusId,
      'adminNotes': adminNotes,
      'rejectionReason': rejectionReason,
      'suggestedRewardPoints': suggestedRewardPoints,
      'suggestedRewardMoney': suggestedRewardMoney,
      'actualRewardPoints': actualRewardPoints,
      'actualRewardMoney': actualRewardMoney,
      'aiAnalysisResult': aiAnalysisResult,
      'completionImageUrl': completionImageUrl,
      'completionNotes': completionNotes,
      'assignedAdminId': assignedAdminId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

// Request Insert Request Model
class RequestInsertRequest {
  final int userId;
  final int locationId;
  final String? title;
  final String? description;
  final int? estimatedCleanupTime;
  final UrgencyLevel urgencyLevel;
  final int wasteTypeId;
  final EstimatedAmount estimatedAmount;
  final DateTime? proposedDate;
  final String? proposedTime;
  final int statusId;
  final String? adminNotes;
  final String? rejectionReason;
  final int suggestedRewardPoints;
  final double suggestedRewardMoney;
  final String? aiAnalysisResult;
  final int? assignedAdminId;
  final List<String>? photoUrls;

  RequestInsertRequest({
    required this.userId,
    required this.locationId,
    this.title,
    this.description,
    this.estimatedCleanupTime,
    required this.urgencyLevel,
    required this.wasteTypeId,
    required this.estimatedAmount,
    this.proposedDate,
    this.proposedTime,
    required this.statusId,
    this.adminNotes,
    this.rejectionReason,
    required this.suggestedRewardPoints,
    required this.suggestedRewardMoney,
    this.aiAnalysisResult,
    this.assignedAdminId,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'locationId': locationId,
      'title': title,
      'description': description,
      'estimatedCleanupTime': estimatedCleanupTime,
      'urgencyLevel': urgencyLevel.index,
      'wasteTypeId': wasteTypeId,
      'estimatedAmount': estimatedAmount.index,
      'proposedDate': proposedDate?.toIso8601String(),
      'proposedTime': proposedTime,
      'statusId': statusId,
      'adminNotes': adminNotes,
      'rejectionReason': rejectionReason,
      'suggestedRewardPoints': suggestedRewardPoints,
      'suggestedRewardMoney': suggestedRewardMoney,
      'aiAnalysisResult': aiAnalysisResult,
      'assignedAdminId': assignedAdminId,
      'photoUrls': photoUrls,
    };
  }
}

// Request Update Request Model
class RequestUpdateRequest {
  final int id;
  final int? locationId;
  final String? title;
  final String? description;
  final int? estimatedCleanupTime;
  final UrgencyLevel? urgencyLevel;
  final int? wasteTypeId;
  final EstimatedAmount? estimatedAmount;
  final DateTime? proposedDate;
  final String? proposedTime;
  final int? statusId;
  final String? adminNotes;
  final String? rejectionReason;
  final int? suggestedRewardPoints;
  final double? suggestedRewardMoney;
  final int? actualRewardPoints;
  final double? actualRewardMoney;
  final String? aiAnalysisResult;
  final String? completionImageUrl;
  final String? completionNotes;
  final int? assignedAdminId;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final List<String>? photoUrls;

  RequestUpdateRequest({
    required this.id,
    this.locationId,
    this.title,
    this.description,
    this.estimatedCleanupTime,
    this.urgencyLevel,
    this.wasteTypeId,
    this.estimatedAmount,
    this.proposedDate,
    this.proposedTime,
    this.statusId,
    this.adminNotes,
    this.rejectionReason,
    this.suggestedRewardPoints,
    this.suggestedRewardMoney,
    this.actualRewardPoints,
    this.actualRewardMoney,
    this.aiAnalysisResult,
    this.completionImageUrl,
    this.completionNotes,
    this.assignedAdminId,
    this.approvedAt,
    this.completedAt,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (locationId != null) data['locationId'] = locationId;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (estimatedCleanupTime != null) data['estimatedCleanupTime'] = estimatedCleanupTime;
    if (urgencyLevel != null) data['urgencyLevel'] = urgencyLevel!.index;
    if (wasteTypeId != null) data['wasteTypeId'] = wasteTypeId;
    if (estimatedAmount != null) data['estimatedAmount'] = estimatedAmount!.index;
    if (proposedDate != null) data['proposedDate'] = proposedDate!.toIso8601String();
    if (proposedTime != null) data['proposedTime'] = proposedTime;
    if (statusId != null) data['statusId'] = statusId;
    if (adminNotes != null) data['adminNotes'] = adminNotes;
    if (rejectionReason != null) data['rejectionReason'] = rejectionReason;
    if (suggestedRewardPoints != null) data['suggestedRewardPoints'] = suggestedRewardPoints;
    if (suggestedRewardMoney != null) data['suggestedRewardMoney'] = suggestedRewardMoney;
    if (actualRewardPoints != null) data['actualRewardPoints'] = actualRewardPoints;
    if (actualRewardMoney != null) data['actualRewardMoney'] = actualRewardMoney;
    if (aiAnalysisResult != null) data['aiAnalysisResult'] = aiAnalysisResult;
    if (completionImageUrl != null) data['completionImageUrl'] = completionImageUrl;
    if (completionNotes != null) data['completionNotes'] = completionNotes;
    if (assignedAdminId != null) data['assignedAdminId'] = assignedAdminId;
    if (approvedAt != null) data['approvedAt'] = approvedAt!.toIso8601String();
    if (completedAt != null) data['completedAt'] = completedAt!.toIso8601String();
    if (photoUrls != null) data['photoUrls'] = photoUrls;
    
    return data;
  }
}

// Request Search Object
class RequestSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? text;
  int? status;
  int? wasteTypeId;
  UrgencyLevel? urgencyLevel;
  EstimatedAmount? estimatedAmount;
  int? locationId;
  int? userId;
  int? assignedAdminId;

  RequestSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.text,
    this.status,
    this.wasteTypeId,
    this.urgencyLevel,
    this.estimatedAmount,
    this.locationId,
    this.userId,
    this.assignedAdminId,
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

    if (text != null) data['text'] = text;
    if (status != null) data['status'] = status;
    if (wasteTypeId != null) data['wasteTypeId'] = wasteTypeId;
    if (urgencyLevel != null) data['urgencyLevel'] = urgencyLevel!.index;
    if (estimatedAmount != null) data['estimatedAmount'] = estimatedAmount!.index;
    if (locationId != null) data['locationId'] = locationId;
    if (userId != null) data['userId'] = userId;
    if (assignedAdminId != null) data['assignedAdminId'] = assignedAdminId;

    return data;
  }
}
