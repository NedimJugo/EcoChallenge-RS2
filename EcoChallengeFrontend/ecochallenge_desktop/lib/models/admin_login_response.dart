class AdminLoginResponse {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String userTypeName;
  final DateTime loginTime;
  final String basicAuthCredentials;

  AdminLoginResponse({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userTypeName,
    required this.loginTime,
    required this.basicAuthCredentials,
  });

  factory AdminLoginResponse.fromJson(Map<String, dynamic> json) {
    return AdminLoginResponse(
      id: json['data']['id'],
      username: json['data']['username'],
      firstName: json['data']['firstName'],
      lastName: json['data']['lastName'],
      email: json['data']['email'],
      userTypeName: json['data']['userTypeName'],
      loginTime: DateTime.parse(json['data']['loginTime']),
      basicAuthCredentials: json['basicAuthCredentials'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class AdminProfileResponse {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String userTypeName;

  AdminProfileResponse({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userTypeName,
  });

  factory AdminProfileResponse.fromJson(Map<String, dynamic> json) {
    return AdminProfileResponse(
      id: json['data']['id'],
      username: json['data']['username'],
      firstName: json['data']['firstName'],
      lastName: json['data']['lastName'],
      email: json['data']['email'],
      userTypeName: json['data']['userTypeName'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
