class Event {
  final int id;
  final int creatorUserId;
  final int locationId;
  final String? title;
  final String? description;
  final List<String>? photoUrls;
  final int eventTypeId;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime eventDate;
  final String eventTime;
  final int durationMinutes;
  final bool equipmentProvided;
  final String? equipmentList;
  final String? meetingPoint;
  final int statusId;
  final bool isPaidRequest;
  final int? relatedRequestId;
  final bool adminApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.creatorUserId,
    required this.locationId,
    this.title,
    this.description,
    this.photoUrls,
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
      id: json['id'],
      creatorUserId: json['creatorUserId'],
      locationId: json['locationId'],
      title: json['title'],
      description: json['description'],
      photoUrls: (json['photoUrls'] as List?)?.map((e) => e.toString()).toList(),
      eventTypeId: json['eventTypeId'],
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      eventDate: DateTime.parse(json['eventDate']),
      eventTime: json['eventTime'] != null
          ? _formatTimeSpan(json['eventTime'])
          : '00:00',
      durationMinutes: json['durationMinutes'],
      equipmentProvided: json['equipmentProvided'],
      equipmentList: json['equipmentList'],
      meetingPoint: json['meetingPoint'],
      statusId: json['statusId'],
      isPaidRequest: json['isPaidRequest'],
      relatedRequestId: json['relatedRequestId'],
      adminApproved: json['adminApproved'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static String _formatTimeSpan(dynamic timeSpanJson) {
    final h = timeSpanJson['hours'] ?? 0;
    final m = timeSpanJson['minutes'] ?? 0;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUserId': creatorUserId,
      'locationId': locationId,
      'title': title,
      'description': description,
      'photoUrls': photoUrls,
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
