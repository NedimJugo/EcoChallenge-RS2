enum NotificationType {
  RequestApproved,
  RequestRejected,
  EventReminder,
  RewardReceived,
  BadgeEarned,
  ChatMessage,
  AdminMessage,
}

// Notification Response Model
class NotificationResponse {
  final int id;
  final int userId;
  final NotificationType notificationType;
  final String? title;
  final String? message;
  final bool isRead;
  final bool isPushed;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationResponse({
    required this.id,
    required this.userId,
    required this.notificationType,
    this.title,
    this.message,
    required this.isRead,
    required this.isPushed,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'],
      userId: json['userId'],
      notificationType: NotificationType.values[json['notificationType']],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'],
      isPushed: json['isPushed'],
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'notificationType': notificationType.index,
      'title': title,
      'message': message,
      'isRead': isRead,
      'isPushed': isPushed,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }
}

// Notification Insert Request Model
class NotificationInsertRequest {
  final int userId;
  final NotificationType notificationType;
  final String title;
  final String message;
  final bool isPushed;

  NotificationInsertRequest({
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.message,
    this.isPushed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'notificationType': notificationType.index,
      'title': title,
      'message': message,
      'isPushed': isPushed,
    };
  }
}

// Notification Update Request Model
class NotificationUpdateRequest {
  final int id;
  final NotificationType? notificationType;
  final String? title;
  final String? message;
  final bool? isRead;
  final bool? isPushed;
  final DateTime? readAt;

  NotificationUpdateRequest({
    required this.id,
    this.notificationType,
    this.title,
    this.message,
    this.isRead,
    this.isPushed,
    this.readAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};

    if (notificationType != null)
      data['notificationType'] = notificationType!.index;
    if (title != null) data['title'] = title;
    if (message != null) data['message'] = message;
    if (isRead != null) data['isRead'] = isRead;
    if (isPushed != null) data['isPushed'] = isPushed;
    if (readAt != null) data['readAt'] = readAt!.toIso8601String();

    return data;
  }
}

// Notification Search Object
class NotificationSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? userId;
  NotificationType? notificationType;
  bool? isRead;
  bool? isPushed;

  NotificationSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.userId,
    this.notificationType,
    this.isRead,
    this.isPushed,
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
    if (notificationType != null)
      data['notificationType'] = notificationType!.index;
    if (isRead != null) data['isRead'] = isRead;
    if (isPushed != null) data['isPushed'] = isPushed;

    return data;
  }
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.RequestApproved:
        return 'Request Approved';
      case NotificationType.RequestRejected:
        return 'Request Rejected';
      case NotificationType.EventReminder:
        return 'Event Reminder';
      case NotificationType.RewardReceived:
        return 'Reward Received';
      case NotificationType.BadgeEarned:
        return 'Badge Earned';
      case NotificationType.ChatMessage:
        return 'Chat Message';
      case NotificationType.AdminMessage:
        return 'Admin Message';
    }
  }

  String get iconAsset {
    switch (this) {
      case NotificationType.RequestApproved:
        return 'assets/icons/approved.png';
      case NotificationType.RequestRejected:
        return 'assets/icons/rejected.png';
      case NotificationType.EventReminder:
        return 'assets/icons/event.png';
      case NotificationType.RewardReceived:
        return 'assets/icons/reward.png';
      case NotificationType.BadgeEarned:
        return 'assets/icons/badge.png';
      case NotificationType.ChatMessage:
        return 'assets/icons/chat.png';
      case NotificationType.AdminMessage:
        return 'assets/icons/admin.png';
    }
  }
}
