class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final int isAdmin;
  final int isAllowedInApp;
  final bool isOnline;
  final List<dynamic> loginDetails;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.isAdmin,
    required this.isAllowedInApp,
    required this.isOnline,
    required this.loginDetails,
  });
}
