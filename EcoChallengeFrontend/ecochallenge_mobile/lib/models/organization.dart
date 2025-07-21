class Organization {
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

  Organization({
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

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      category: json['category'],
      isVerified: json['isVerified'],
      isActive: json['isActive'],
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
