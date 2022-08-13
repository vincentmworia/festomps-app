import 'package:flutter/material.dart';

import '../models/user.dart';

class FirebaseUserData with ChangeNotifier {
  User get loggedInUser => _loggedInUser;
  final User _loggedInUser = User(
      id: userData['id'] as String,
      email: userData['email'] as String,
      firstName: userData['firstName'] as String,
      lastName: userData['lastName'] as String,
      password: userData['password'] as String,
      isAdmin: userData['isAdmin'] as int,
      isAllowedInApp: userData['isAllowedInApp'] as int,
      isOnline: userData['isOnline'] as bool,
      loginDetails: userData['loginDetails'] as List<dynamic>);

  static const Map<String, dynamic> userData = {
    "id": "YutDzJGvx4VEPiuKEqL1dhWZsTC2",
    "email": "mworiavin@gmail.com",
    "firstName": "Vincent",
    "lastName": "Mworia",
    "password": "vincentmwendamworia",
    "isAdmin": 5334,
    "isAllowedInApp": 0163,
    "isOnline": true,
    "loginDetails": [
      {
        "login": "2022-07-21T18:27:13.211650",
        "logout": "2022-07-21T18:27:13.235451"
      },
      {
        "login": "2022-07-21T18:27:13.211650",
        "logout": "2022-07-21T18:40:25.602619"
      }
    ]
  };

  bool get switchValue => _switchValue ?? true;
  bool? _switchValue;

  void setSwitchValue(bool value) {
    _switchValue = value;
    //todo Store the switch value in shared preferences api
    notifyListeners();
  }
}
