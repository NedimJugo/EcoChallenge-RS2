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
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AttendanceStatus.Registered,
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

// Event Participant Insert Request Model
class EventParticipantInsertRequest {
  final int eventId;
  final int userId;
  final AttendanceStatus status;
  final int pointsEarned;

  EventParticipantInsertRequest({
    required this.eventId,
    required this.userId,
    this.status = AttendanceStatus.Registered,
    this.pointsEarned = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'status': status.toString().split('.').last,
      'pointsEarned': pointsEarned,
    };
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
    if (status != null) data['status'] = status.toString().split('.').last;
    if (pointsEarned != null) data['pointsEarned'] = pointsEarned;
    
    return data;
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
  Registered,
  Attended,
  Completed,
  Cancelled,
  NoShow,
}