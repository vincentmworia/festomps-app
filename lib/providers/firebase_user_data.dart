import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../widgets/custom_widgets.dart';

class FirebaseUserData with ChangeNotifier {
  static const prefName = 'fingerprintData';

  User? get loggedInUser => _loggedInUser;
  User? _loggedInUser;

  bool get switchValue => _switchValue ?? false;
  bool? _switchValue;

  Future<void> switchValueInit() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(FirebaseUserData.prefName)) {
      _switchValue = true;
    } else {
      _switchValue = false;
    }
  }

  void setLoggedInUser(User usr) {
    _loggedInUser = usr;
    notifyListeners();
  }

  Future<void> setSwitchValue(bool value, BuildContext context) async {
    if (value) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content:
                    Custom.normalText('Do you want to login with fingerprint?'),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('No')),
                      ElevatedButton(
                          onPressed: () async {
                            _switchValue = value;
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString(
                                prefName,
                                json.encode({
                                  'email': _loggedInUser!.email,
                                  'password': _loggedInUser!.password,
                                }));
                            Future.delayed(Duration.zero)
                                .then((_) => Navigator.pop(context));
                          },
                          child: const Text('Yes')),
                    ],
                  )
                ],
              ));
    } else {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(prefName);
      _switchValue = false;
    }
    notifyListeners();
  }
}
