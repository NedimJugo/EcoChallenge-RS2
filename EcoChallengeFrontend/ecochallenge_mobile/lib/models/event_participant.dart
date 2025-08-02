
// Event Participant Response Model
class EventParticipantResponse {
  final int id;
  final int eventId;
  final int userId;
  final DateTime joinedAt;
  final AttendanceStatus status;
  final int pointsEarned;

  EventParticipantResponse({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.joinedAt,
    required this.status,
    required this.pointsEarned,
  });

  factory EventParticipantResponse.fromJson(Map<String, dynamic> json) {
    return EventParticipantResponse(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      joinedAt: DateTime.parse(json['joinedAt']),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['status'].toString().toLowerCase(),
        orElse: () => AttendanceStatus.registered,
      ),
      pointsEarned: json['pointsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'joinedAt': joinedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'pointsEarned': pointsEarned,
    };
  }
}

// FIXED: Event Participant Insert Request Model
class EventParticipantInsertRequest {
  final int eventId;
  final int userId;
  final AttendanceStatus status;
  final int pointsEarned;

  EventParticipantInsertRequest({
    required this.eventId,
    required this.userId,
    this.status = AttendanceStatus.registered,
    this.pointsEarned = 0,
  });

  // FIXED: Remove the "request" wrapper and send data directly
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'status': _statusToInt(status), // Convert to integer
      'pointsEarned': pointsEarned,
    };
  }

  // Convert AttendanceStatus enum to integer (matching backend enum values)
  int _statusToInt(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.registered:
        return 0;
      case AttendanceStatus.attended:
        return 1;
      case AttendanceStatus.completed:
        return 2;
      case AttendanceStatus.cancelled:
        return 3;
      case AttendanceStatus.noShow:
        return 4;
    }
  }
}

// Event Participant Update Request Model
class EventParticipantUpdateRequest {
  final int id;
  final int? eventId;
  final int? userId;
  final AttendanceStatus? status;
  final int? pointsEarned;

  EventParticipantUpdateRequest({
    required this.id,
    this.eventId,
    this.userId,
    this.status,
    this.pointsEarned,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (eventId != null) data['eventId'] = eventId;
    if (userId != null) data['userId'] = userId;
    if (status != null) data['status'] = _statusToInt(status!);
    if (pointsEarned != null) data['pointsEarned'] = pointsEarned;
    
    return data;
  }

  int _statusToInt(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.registered:
        return 0;
      case AttendanceStatus.attended:
        return 1;
      case AttendanceStatus.completed:
        return 2;
      case AttendanceStatus.cancelled:
        return 3;
      case AttendanceStatus.noShow:
        return 4;
    }
  }
}

// Event Participant Search Object
class EventParticipantSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? eventId;
  int? userId;

  EventParticipantSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.eventId,
    this.userId,
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
    if (eventId != null) data['eventId'] = eventId;
    if (userId != null) data['userId'] = userId;
    return data;
  }
}

// Attendance Status Enum
enum AttendanceStatus {
  registered,  // 0
  attended,    // 1
  completed,   // 2
  cancelled,   // 3
  noShow,      // 4
}

// Extension to get display names
extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.registered:
        return 'Registered';
      case AttendanceStatus.attended:
        return 'Attended';
      case AttendanceStatus.completed:
        return 'Completed';
      case AttendanceStatus.cancelled:
        return 'Cancelled';
      case AttendanceStatus.noShow:
        return 'No Show';
    }
  }
}
