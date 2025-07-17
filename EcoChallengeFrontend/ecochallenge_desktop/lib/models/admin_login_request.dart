class AdminLoginRequest {
  final String username;
  final String password;

  AdminLoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
