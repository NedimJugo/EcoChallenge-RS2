
class EventResponse {
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
  final String eventTime; // TimeSpan as string (HH:mm:ss)
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

  EventResponse({
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

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'],
      creatorUserId: json['creatorUserId'],
      locationId: json['locationId'],
      title: json['title'],
      description: json['description'],
      photoUrls: json['photoUrls'] != null 
          ? List<String>.from(json['photoUrls'])
          : null,
      eventTypeId: json['eventTypeId'],
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      eventDate: DateTime.parse(json['eventDate']),
      eventTime: json['eventTime'],
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

// Event Insert Request Model
class EventInsertRequest {
  final int creatorUserId;
  final int locationId;
  final String title;
  final String? description;
  final int eventTypeId;
  final int maxParticipants;
  final DateTime eventDate;
  final String eventTime; // TimeSpan as string (HH:mm:ss)
  final int durationMinutes;
  final bool equipmentProvided;
  final String? equipmentList;
  final String? meetingPoint;
  final int statusId;
  final bool adminApproved;
  final List<String>? photoUrls; // For file uploads, you'd handle this differently

  EventInsertRequest({
    required this.creatorUserId,
    required this.locationId,
    required this.title,
    this.description,
    required this.eventTypeId,
    this.maxParticipants = 0,
    required this.eventDate,
    required this.eventTime,
    this.durationMinutes = 120,
    this.equipmentProvided = false,
    this.equipmentList,
    this.meetingPoint,
    required this.statusId,
    this.adminApproved = false,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'creatorUserId': creatorUserId,
      'locationId': locationId,
      'title': title,
      'description': description,
      'eventTypeId': eventTypeId,
      'maxParticipants': maxParticipants,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'durationMinutes': durationMinutes,
      'equipmentProvided': equipmentProvided,
      'equipmentList': equipmentList,
      'meetingPoint': meetingPoint,
      'statusId': statusId,
      'adminApproved': adminApproved,
      'photoUrls': photoUrls,
    };
  }
}

// Event Update Request Model
class EventUpdateRequest {
  final int id;
  final int? creatorUserId;
  final int? locationId;
  final String? title;
  final String? description;
  final int? eventTypeId;
  final int? maxParticipants;
  final DateTime? eventDate;
  final String? eventTime;
  final int? durationMinutes;
  final bool? equipmentProvided;
  final String? equipmentList;
  final String? meetingPoint;
  final int? statusId;
  final bool? adminApproved;
  final List<String>? photoUrls;

  EventUpdateRequest({
    required this.id,
    this.creatorUserId,
    this.locationId,
    this.title,
    this.description,
    this.eventTypeId,
    this.maxParticipants,
    this.eventDate,
    this.eventTime,
    this.durationMinutes,
    this.equipmentProvided,
    this.equipmentList,
    this.meetingPoint,
    this.statusId,
    this.adminApproved,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (creatorUserId != null) data['creatorUserId'] = creatorUserId;
    if (locationId != null) data['locationId'] = locationId;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (eventTypeId != null) data['eventTypeId'] = eventTypeId;
    if (maxParticipants != null) data['maxParticipants'] = maxParticipants;
    if (eventDate != null) data['eventDate'] = eventDate!.toIso8601String();
    if (eventTime != null) data['eventTime'] = eventTime;
    if (durationMinutes != null) data['durationMinutes'] = durationMinutes;
    if (equipmentProvided != null) data['equipmentProvided'] = equipmentProvided;
    if (equipmentList != null) data['equipmentList'] = equipmentList;
    if (meetingPoint != null) data['meetingPoint'] = meetingPoint;
    if (statusId != null) data['statusId'] = statusId;
    if (adminApproved != null) data['adminApproved'] = adminApproved;
    if (photoUrls != null) data['photoUrls'] = photoUrls;
    
    return data;
  }
}

// Event Search Object
class EventSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  String? text;
  int? status;
  int? type;
  int? creatorUserId;
  int? locationId;

  EventSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.text,
    this.status,
    this.type,
    this.creatorUserId,
    this.locationId,
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
    if (type != null) data['type'] = type;
    if (creatorUserId != null) data['creatorUserId'] = creatorUserId;
    if (locationId != null) data['locationId'] = locationId;

    return data;
  }
}
