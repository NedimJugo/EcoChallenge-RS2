// Badge Response model
class BadgeResponse {
  final int id;
  final String? name;
  final String? description;
  final String? iconUrl;
  final int badgeTypeId;
  final int criteriaTypeId;
  final int criteriaValue;
  final bool isActive;
  final DateTime createdAt;

  BadgeResponse({
    required this.id,
    this.name,
    this.description,
    this.iconUrl,
    required this.badgeTypeId,
    required this.criteriaTypeId,
    required this.criteriaValue,
    required this.isActive,
    required this.createdAt,
  });

  factory BadgeResponse.fromJson(Map<String, dynamic> json) {
    return BadgeResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      badgeTypeId: json['badgeTypeId'],
      criteriaTypeId: json['criteriaTypeId'],
      criteriaValue: json['criteriaValue'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'badgeTypeId': badgeTypeId,
      'criteriaTypeId': criteriaTypeId,
      'criteriaValue': criteriaValue,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Badge Insert Request model
class BadgeInsertRequest {
  final String name;
  final String? description;
  final String? iconUrl; // Note: File upload handling would need special implementation
  final int badgeTypeId;
  final int criteriaTypeId;
  final int criteriaValue;
  final bool isActive;

  BadgeInsertRequest({
    required this.name,
    this.description,
    this.iconUrl,
    required this.badgeTypeId,
    required this.criteriaTypeId,
    required this.criteriaValue,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'badgeTypeId': badgeTypeId,
      'criteriaTypeId': criteriaTypeId,
      'criteriaValue': criteriaValue,
      'isActive': isActive,
    };
  }
}

// Badge Update Request model
class BadgeUpdateRequest {
  final String? name;
  final String? description;
  final String? iconUrl;
  final int? badgeTypeId;
  final int? criteriaTypeId;
  final int? criteriaValue;
  final bool? isActive;

  BadgeUpdateRequest({
    this.name,
    this.description,
    this.iconUrl,
    this.badgeTypeId,
    this.criteriaTypeId,
    this.criteriaValue,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (iconUrl != null) data['iconUrl'] = iconUrl;
    if (badgeTypeId != null) data['badgeTypeId'] = badgeTypeId;
    if (criteriaTypeId != null) data['criteriaTypeId'] = criteriaTypeId;
    if (criteriaValue != null) data['criteriaValue'] = criteriaValue;
    if (isActive != null) data['isActive'] = isActive;
    
    return data;
  }
}
