// Location Type enum
enum LocationType {
  park,
  beach,
  forest,
  urban,
  other,
}

extension LocationTypeExtension on LocationType {
  String get displayName {
    switch (this) {
      case LocationType.park:
        return 'Park';
      case LocationType.beach:
        return 'Beach';
      case LocationType.forest:
        return 'Forest';
      case LocationType.urban:
        return 'Urban';
      case LocationType.other:
        return 'Other';
    }
  }

  static LocationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'park':
        return LocationType.park;
      case 'beach':
        return LocationType.beach;
      case 'forest':
        return LocationType.forest;
      case 'urban':
        return LocationType.urban;
      case 'other':
      default:
        return LocationType.other;
    }
  }
}

// Location Response model
class LocationResponse {
  final int id;
  final String? name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final LocationType locationType;
  final DateTime createdAt;

  LocationResponse({
    required this.id,
    this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    required this.locationType,
    required this.createdAt,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      locationType: LocationTypeExtension.fromString(json['locationType'].toString()),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'locationType': locationType.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Location Insert Request model
class LocationInsertRequest {
  final String? name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final LocationType locationType;

  LocationInsertRequest({
    this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    required this.locationType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'locationType': locationType.index,
    };
  }
}

// Location Update Request model
class LocationUpdateRequest {
  final String? name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final LocationType? locationType;

  LocationUpdateRequest({
    this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.locationType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (country != null) data['country'] = country;
    if (postalCode != null) data['postalCode'] = postalCode;
    if (locationType != null) data['locationType'] = locationType!.index;
    
    return data;
  }
}
