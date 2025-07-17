// Request model for user login
class UserLoginRequest {
  final String username;
  final String password;

  UserLoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

// Response model for authenticated user
class UserResponse {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? city;
  final String? country;
  final int totalPoints;
  final int totalCleanups;
  final int totalEventsOrganized;
  final int totalEventsParticipated;
  final int userTypeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final DateTime? deactivatedAt;
  final String? userTypeName;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.city,
    this.country,
    required this.totalPoints,
    required this.totalCleanups,
    required this.totalEventsOrganized,
    required this.totalEventsParticipated,
    required this.userTypeId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.deactivatedAt,
    this.userTypeName,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImageUrl: json['profileImageUrl'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      city: json['city'],
      country: json['country'],
      totalPoints: json['totalPoints'],
      totalCleanups: json['totalCleanups'],
      totalEventsOrganized: json['totalEventsOrganized'],
      totalEventsParticipated: json['totalEventsParticipated'],
      userTypeId: json['userTypeId'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      deactivatedAt: json['deactivatedAt'] != null
          ? DateTime.parse(json['deactivatedAt'])
          : null,
      userTypeName: json['userTypeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'city': city,
      'country': country,
      'totalPoints': totalPoints,
      'totalCleanups': totalCleanups,
      'totalEventsOrganized': totalEventsOrganized,
      'totalEventsParticipated': totalEventsParticipated,
      'userTypeId': userTypeId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'deactivatedAt': deactivatedAt?.toIso8601String(),
      'userTypeName': userTypeName,
    };
  }
}
