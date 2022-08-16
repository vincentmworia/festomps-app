class Admin {
  final String localId;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final bool admin;
  final bool allowedInApp;
  final bool online;
  List<dynamic> loginData;

  Admin({
    required this.localId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.admin,
    required this.allowedInApp,
    required this.online,
    required this.loginData,
  });
}
