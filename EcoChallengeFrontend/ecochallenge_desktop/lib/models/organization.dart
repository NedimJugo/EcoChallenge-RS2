import 'dart:io';

// Organization Response model
class OrganizationResponse {
  final int id;
  final String? name;
  final String? description;
  final String? website;
  final String? logoUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? category;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganizationResponse({
    required this.id,
    this.name,
    this.description,
    this.website,
    this.logoUrl,
    this.contactEmail,
    this.contactPhone,
    this.category,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      category: json['category'],
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'website': website,
      'logoUrl': logoUrl,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'category': category,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Organization Insert Request model
class OrganizationInsertRequest {
  final String name;
  final String? description;
  final String? website;
  final File? logoImage; // For file upload
  final String? contactEmail;
  final String? contactPhone;
  final String? category;
  final bool isVerified;
  final bool isActive;

  OrganizationInsertRequest({
    required this.name,
    this.description,
    this.website,
    this.logoImage,
    this.contactEmail,
    this.contactPhone,
    this.category,
    this.isVerified = false,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'website': website,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'category': category,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }
}

// Organization Update Request model
class OrganizationUpdateRequest {
  final String? name;
  final String? description;
  final String? website;
  final File? logoImage; // For file upload
  final String? contactEmail;
  final String? contactPhone;
  final String? category;
  final bool? isVerified;
  final bool? isActive;

  OrganizationUpdateRequest({
    this.name,
    this.description,
    this.website,
    this.logoImage,
    this.contactEmail,
    this.contactPhone,
    this.category,
    this.isVerified,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (website != null) data['website'] = website;
    if (contactEmail != null) data['contactEmail'] = contactEmail;
    if (contactPhone != null) data['contactPhone'] = contactPhone;
    if (category != null) data['category'] = category;
    if (isVerified != null) data['isVerified'] = isVerified;
    if (isActive != null) data['isActive'] = isActive;
    
    return data;
  }
}
