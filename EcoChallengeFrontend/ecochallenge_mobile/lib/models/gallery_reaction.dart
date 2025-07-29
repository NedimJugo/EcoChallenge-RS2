// Gallery Reaction Response Model
class GalleryReactionResponse {
  final int id;
  final int galleryShowcaseId;
  final int userId;
  final ReactionType reactionType;
  final DateTime createdAt;

  GalleryReactionResponse({
    required this.id,
    required this.galleryShowcaseId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
  });

  factory GalleryReactionResponse.fromJson(Map<String, dynamic> json) {
  ReactionType parseReaction(dynamic value) {
    if (value is int) {
      // 0=like, 1=dislike (matches your backend enum)
      return ReactionType.values[value];
    } else if (value is String) {
      return ReactionType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
        orElse: () => ReactionType.like,
      );
    }
    return ReactionType.like;
  }

  return GalleryReactionResponse(
    id: json['id'],
    galleryShowcaseId: json['galleryShowcaseId'],
    userId: json['userId'],
    reactionType: parseReaction(json['reactionType']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'galleryShowcaseId': galleryShowcaseId,
      'userId': userId,
      'reactionType': reactionType.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum ReactionType {
  like,
  dislike,
  report
}

// Gallery Reaction Insert Request Model - Updated
class GalleryReactionInsertRequest {
  final int galleryShowcaseId;
  final int userId;
  final ReactionType reactionType;

  GalleryReactionInsertRequest({
    required this.galleryShowcaseId,
    required this.userId,
    required this.reactionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'galleryShowcaseId': galleryShowcaseId,
      'userId': userId,
      'reactionType': _getReactionTypeValue(reactionType), // Convert to int
    };
  }

  // Helper method to convert enum to int
  int _getReactionTypeValue(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.like:
        return 0; // Check your backend enum values
      case ReactionType.dislike:
        return 1; // Check your backend enum values  
      case ReactionType.report:
        return 2; // Check your backend enum values
    }
  }
}

// Gallery Reaction Update Request Model - Updated
class GalleryReactionUpdateRequest {
  final int id;
  final ReactionType reactionType;

  GalleryReactionUpdateRequest({
    required this.id,
    required this.reactionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reactionType': _getReactionTypeValue(reactionType), // Convert to int
    };
  }

  // Helper method to convert enum to int
  int _getReactionTypeValue(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.like:
        return 0; // Check your backend enum values
      case ReactionType.dislike:
        return 1; // Check your backend enum values
      case ReactionType.report:
        return 2; // Check your backend enum values
    }
  }
}

// Gallery Reaction Search Object
class GalleryReactionSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? userId;
  int? galleryShowcaseId;

  GalleryReactionSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.userId,
    this.galleryShowcaseId,
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
    if (galleryShowcaseId != null) data['galleryShowcaseId'] = galleryShowcaseId;

    return data;
  }
}