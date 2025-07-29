// Gallery Showcase Response Model
import 'dart:io';

class GalleryShowcaseResponse {
  final int id;
  final int? requestId;
  final int? eventId;
  final int locationId;
  final int createdByAdminId;
  final String beforeImageUrl;
  final String afterImageUrl;
  final String? title;
  final String? description;
  final int likesCount;
  final int dislikesCount;
  final bool isFeatured;
  final bool isApproved;
  final bool isReported;
  final int reportCount;
  final DateTime createdAt;

  GalleryShowcaseResponse({
    required this.id,
    this.requestId,
    this.eventId,
    required this.locationId,
    required this.createdByAdminId,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.title,
    this.description,
    required this.likesCount,
    required this.dislikesCount,
    required this.isFeatured,
    required this.isApproved,
    required this.isReported,
    required this.reportCount,
    required this.createdAt,
  });

  factory GalleryShowcaseResponse.fromJson(Map<String, dynamic> json) {
    return GalleryShowcaseResponse(
      id: json['id'],
      requestId: json['requestId'],
      eventId: json['eventId'],
      locationId: json['locationId'],
      createdByAdminId: json['createdByAdminId'],
      beforeImageUrl: json['beforeImageUrl'],
      afterImageUrl: json['afterImageUrl'],
      title: json['title'],
      description: json['description'],
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      isApproved: json['isApproved'] ?? false,
      isReported: json['isReported'] ?? false,
      reportCount: json['reportCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'eventId': eventId,
      'locationId': locationId,
      'createdByAdminId': createdByAdminId,
      'beforeImageUrl': beforeImageUrl,
      'afterImageUrl': afterImageUrl,
      'title': title,
      'description': description,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'isFeatured': isFeatured,
      'isApproved': isApproved,
      'isReported': isReported,
      'reportCount': reportCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Gallery Showcase Insert Request Model
class GalleryShowcaseInsertRequest {
  final int? requestId;
  final int? eventId;
  final int locationId;
  final int createdByAdminId;
  final File beforeImage;
  final File afterImage;
  final String? title;
  final String? description;
  final bool isFeatured;

  GalleryShowcaseInsertRequest({
    this.requestId,
    this.eventId,
    required this.locationId,
    required this.createdByAdminId,
    required this.beforeImage,
    required this.afterImage,
    this.title,
    this.description,
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'eventId': eventId,
      'locationId': locationId,
      'createdByAdminId': createdByAdminId,
      'title': title,
      'description': description,
      'isFeatured': isFeatured,
    };
  }
}

// Gallery Showcase Update Request Model
class GalleryShowcaseUpdateRequest {
  final int id;
  final int? requestId;
  final int? eventId;
  final int? locationId;
  final int? createdByAdminId;
  final File? beforeImage;
  final File? afterImage;
  final String? title;
  final String? description;
  final bool? isFeatured;
  final bool? isApproved;
  final bool? isReported;

  GalleryShowcaseUpdateRequest({
    required this.id,
    this.requestId,
    this.eventId,
    this.locationId,
    this.createdByAdminId,
    this.beforeImage,
    this.afterImage,
    this.title,
    this.description,
    this.isFeatured,
    this.isApproved,
    this.isReported,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    
    if (requestId != null) data['requestId'] = requestId;
    if (eventId != null) data['eventId'] = eventId;
    if (locationId != null) data['locationId'] = locationId;
    if (createdByAdminId != null) data['createdByAdminId'] = createdByAdminId;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (isFeatured != null) data['isFeatured'] = isFeatured;
    if (isApproved != null) data['isApproved'] = isApproved;
    if (isReported != null) data['isReported'] = isReported;
    
    return data;
  }
}

// Gallery Showcase Search Object
class GalleryShowcaseSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? locationId;
  int? createdByAdminId;
  bool? isApproved;
  bool? isFeatured;
  String? title;

  GalleryShowcaseSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.locationId,
    this.createdByAdminId,
    this.isApproved,
    this.isFeatured,
    this.title,
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

    if (locationId != null) data['locationId'] = locationId;
    if (createdByAdminId != null) data['createdByAdminId'] = createdByAdminId;
    if (isApproved != null) data['isApproved'] = isApproved;
    if (isFeatured != null) data['isFeatured'] = isFeatured;
    if (title != null) data['title'] = title;

    return data;
  }
}
