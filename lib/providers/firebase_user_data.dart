import 'package:flutter/material.dart';

import '../models/user.dart';
import '../private_data.dart';

class FirebaseUserData with ChangeNotifier {
  User? get loggedInUser => _loggedInUser;
  User? _loggedInUser;

  bool get switchValue => _switchValue ?? false;
  bool? _switchValue;

  void setLoggedInUser(User usr) {
    _loggedInUser = usr;
    notifyListeners();
  }

  void setSwitchValue(bool value) {
    // todo prompt whether the user will auto log in with fingerprint, if true,
    // store in shared preferences api and enable autologin
    _switchValue = value;
    //todo Store the switch value in shared preferences api
    notifyListeners();
  }
}
