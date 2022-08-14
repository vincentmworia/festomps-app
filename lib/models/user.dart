class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  int admin;
  int allowedInApp;
  bool online;
  List<dynamic> loginDetails;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.admin,
    required this.allowedInApp,
    required this.online,
    required this.loginDetails,
  });

  static User fromMap(Map<String, dynamic> user) => User(
        id: user['localId'] as String,
        email: user['email'] as String,
        firstName: user['firstname'] as String,
        lastName: user['lastname'] as String,
        password: user['password'] as String,
        admin: user['admin'] as int,
        allowedInApp: user['allowedInApp'] as int,
        online: user['online'] as bool,
        loginDetails: user['loginDetails'] as List<dynamic>,
      );

  Map<String, dynamic> toMap() => {
        "localId": id,
        "email": email,
        "firstname": firstName,
        "lastname": lastName,
        "password": password,
        "amin": admin,
        "allowedInApp": allowedInApp,
        "online": online,
        // "loginDetails": [addLoginDetails()],
      };
}
