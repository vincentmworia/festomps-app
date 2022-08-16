class User {
  final String localId;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  Map<String, dynamic> admin;
  Map<String, dynamic> allowedInApp;
  Map<String, dynamic> online;
  Map<dynamic, dynamic> loginDetails;

  User({
    required this.localId,
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
        localId: user['localId'] as String,
        email: user['email'] as String,
        firstName: user['firstname'] as String,
        lastName: user['lastname'] as String,
        password: user['password'] as String,
        admin: user['admin'] as Map<String,dynamic>,
        allowedInApp: user['allowedInApp'] as Map<String,dynamic>,
        online: user['online'] as Map<String,dynamic>,
        loginDetails: user['loginDetails'] as Map<dynamic, dynamic>,
      );

// Map<String, dynamic> toMap() => {
//       "localId": localId,
//       "email": email,
//       "firstname": firstName,
//       "lastname": lastName,
//       "password": password,
//       "admin": admin,
//       "allowedInApp": allowedInApp,
//       "online": online,
//       // "loginDetails": [addLoginDetails()],
//     };
}
