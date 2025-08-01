
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

class UserRegisterRequest {
  final String username;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final int userTypeId;

  UserRegisterRequest({
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.userTypeId = 2, // default user role id
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'passwordHash': passwordHash,
        'firstName': firstName,
        'lastName': lastName,
        'userTypeId': userTypeId,
      };
}
// Insert request matching your backend UserInsertRequest
class UserInsertRequest {
  final String username;
  final String email;
  final String passwordHash;
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
  final DateTime? lastLogin;
  final DateTime? deactivatedAt;

  UserInsertRequest({
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.city,
    this.country,
    this.totalPoints = 0,
    this.totalCleanups = 0,
    this.totalEventsOrganized = 0,
    this.totalEventsParticipated = 0,
    required this.userTypeId,
    this.isActive = true,
    this.lastLogin,
    this.deactivatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
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
      'lastLogin': lastLogin?.toIso8601String(),
      'deactivatedAt': deactivatedAt?.toIso8601String(),
    };
  }
}

// Update request matching your backend UserUpdateRequest
class UserUpdateRequest {
  final String? username;
  final String? email;
  final String? passwordHash;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? city;
  final String? country;
  final int? totalPoints;
  final int? totalCleanups;
  final int? totalEventsOrganized;
  final int? totalEventsParticipated;
  final int? userTypeId;
  final bool? isActive;
  final DateTime? lastLogin;
  final DateTime? deactivatedAt;

  UserUpdateRequest({
    this.username,
    this.email,
    this.passwordHash,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.city,
    this.country,
    this.totalPoints,
    this.totalCleanups,
    this.totalEventsOrganized,
    this.totalEventsParticipated,
    this.userTypeId,
    this.isActive,
    this.lastLogin,
    this.deactivatedAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (passwordHash != null) data['passwordHash'] = passwordHash;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (city != null) data['city'] = city;
    if (country != null) data['country'] = country;
    if (totalPoints != null) data['totalPoints'] = totalPoints;
    if (totalCleanups != null) data['totalCleanups'] = totalCleanups;
    if (totalEventsOrganized != null) data['totalEventsOrganized'] = totalEventsOrganized;
    if (totalEventsParticipated != null) data['totalEventsParticipated'] = totalEventsParticipated;
    if (userTypeId != null) data['userTypeId'] = userTypeId;
    if (isActive != null) data['isActive'] = isActive;
    if (lastLogin != null) data['lastLogin'] = lastLogin!.toIso8601String();
    if (deactivatedAt != null) data['deactivatedAt'] = deactivatedAt!.toIso8601String();
    
    return data;
  }
}

// Add this UserSearchObject class to your user.dart file or create a separate file

class UserSearchObject {
  int? page;
  int? pageSize;
  String sortBy;
  bool desc;
  bool includeTotalCount;
  bool retrieveAll;
  int? id;
  String? username;
  String? email;

  UserSearchObject({
    this.page = 0,
    this.pageSize = 20,
    this.sortBy = "Id",
    this.desc = false,
    this.includeTotalCount = true,
    this.retrieveAll = false,
    this.id,
    this.username,
    this.email,
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
    
    if (id != null) data['id'] = id;
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    
    return data;
  }
}

