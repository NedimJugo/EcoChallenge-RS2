class Request {
  final int id;
  final int userId;
  final int locationId;
  final String? title;
  final String? description;
  final String? imageUrl;
  final int? estimatedCleanupTime;
  final int urgencyLevel; // Changed from String to int (enum value)
  final int wasteTypeId;
  final int estimatedAmount; // Changed from String to int (enum value)
  final DateTime? proposedDate;
  final String? proposedTime;
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

  Request({
    required this.id,
    required this.userId,
    required this.locationId,
    this.title,
    this.description,
    this.imageUrl,
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

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      userId: json['userId'],
      locationId: json['locationId'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      estimatedCleanupTime: json['estimatedCleanupTime'],
      urgencyLevel: json['urgencyLevel'],
      wasteTypeId: json['wasteTypeId'],
      estimatedAmount: json['estimatedAmount'],
      proposedDate: json['proposedDate'] != null
          ? DateTime.parse(json['proposedDate'])
          : null,
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
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'locationId': locationId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'estimatedCleanupTime': estimatedCleanupTime,
      'urgencyLevel': urgencyLevel,
      'wasteTypeId': wasteTypeId,
      'estimatedAmount': estimatedAmount,
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

  /// Helper: Convert urgencyLevel enum int to string label
  String get urgencyLevelLabel {
    switch (urgencyLevel) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      case 3:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  /// Helper: Convert estimatedAmount enum int to string label
  String get estimatedAmountLabel {
    switch (estimatedAmount) {
      case 0:
        return 'Small';
      case 1:
        return 'Medium';
      case 2:
        return 'Large';
      case 3:
        return 'VeryLarge';
      default:
        return 'Unknown';
    }
  }
}
