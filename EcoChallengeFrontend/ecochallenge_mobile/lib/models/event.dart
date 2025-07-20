class Event {
  final int id;
  final int creatorUserId;
  final int locationId;
  final String? title;              // Nullable in C#
  final String? description;        // Nullable in C#
  final String? imageUrl;          // Nullable in C#
  final int eventTypeId;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime eventDate;
  final String eventTime;          // TimeSpan from C# becomes String
  final int durationMinutes;
  final bool equipmentProvided;
  final String? equipmentList;     // Nullable in C#
  final String? meetingPoint;      // Nullable in C#
  final int statusId;
  final bool isPaidRequest;
  final int? relatedRequestId;     // Nullable in C#
  final bool adminApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.creatorUserId,
    required this.locationId,
    this.title,
    this.description,
    this.imageUrl,
    required this.eventTypeId,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.eventDate,
    required this.eventTime,
    required this.durationMinutes,
    required this.equipmentProvided,
    this.equipmentList,
    this.meetingPoint,
    required this.statusId,
    required this.isPaidRequest,
    this.relatedRequestId,
    required this.adminApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      creatorUserId: json['creatorUserId'] as int,
      locationId: json['locationId'] as int,
      title: json['title'] as String?,                    // Safe null handling
      description: json['description'] as String?,        // Safe null handling
      imageUrl: json['imageUrl'] as String?,             // Safe null handling
      eventTypeId: json['eventTypeId'] as int,
      maxParticipants: json['maxParticipants'] as int,
      currentParticipants: json['currentParticipants'] as int,
      eventDate: DateTime.parse(json['eventDate'] as String),
      eventTime: json['eventTime'] as String,            // TimeSpan as String
      durationMinutes: json['durationMinutes'] as int,
      equipmentProvided: json['equipmentProvided'] as bool,
      equipmentList: json['equipmentList'] as String?,   // Safe null handling
      meetingPoint: json['meetingPoint'] as String?,     // Safe null handling
      statusId: json['statusId'] as int,
      isPaidRequest: json['isPaidRequest'] as bool,
      relatedRequestId: json['relatedRequestId'] as int?, // Safe null handling
      adminApproved: json['adminApproved'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUserId': creatorUserId,
      'locationId': locationId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'eventTypeId': eventTypeId,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'durationMinutes': durationMinutes,
      'equipmentProvided': equipmentProvided,
      'equipmentList': equipmentList,
      'meetingPoint': meetingPoint,
      'statusId': statusId,
      'isPaidRequest': isPaidRequest,
      'relatedRequestId': relatedRequestId,
      'adminApproved': adminApproved,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}