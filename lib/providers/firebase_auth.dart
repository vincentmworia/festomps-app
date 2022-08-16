import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../private_data.dart';
import '../providers/firebase_user_data.dart';
import '../models/signIn.dart';
import '../models/user.dart';
import '../screens/login_screen.dart';

class FirebaseAuthenticationHandler with ChangeNotifier {
  static String? _token;
  static String? _expiresIn;
  static DateTime? _loginTime;
  static DateTime? _logoutTime;

  String? get token => _token;

  // todo, token expire? force log out and reset preferences
  static Uri _urlAuth(String operation) => Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:${operation}key=$webApiKey');

  static String getErrorMessage(String errorTitle) {
    var message = 'Operation failed';

    if (errorTitle.contains('EMAIL_EXISTS')) {
      message = 'Email is already in use';
    }
    if (errorTitle.contains('CREDENTIAL_TOO_OLD_LOGIN_AGAIN')) {
      message = 'Select a new email';
    } else if (errorTitle.contains('INVALID_EMAIL')) {
      message = 'This is not a valid email address';
    } else if (errorTitle.contains('NOT_ALLOWED')) {
      message = 'User needs to be allowed by the admin';
    } else if (errorTitle.contains('TOO_MANY_ATTEMPTS_TRY_LATER:')) {
      message =
          'We have blocked all requests from this device due to unusual activity. Try again later.';
    } else if (errorTitle.contains('EMAIL_NOT_FOUND')) {
      message = 'Could not find a user with that email.';
    } else if (errorTitle.contains('WEAK_PASSWORD')) {
      message = 'Password must be at least 6 characters';
    } else if (errorTitle.contains('INVALID_PASSWORD')) {
      message = 'Invalid password';
    } else {
      message = message;
    }
    return message;
  }

  static Future<String> signup({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    String? message;
    final response = await http.post(_urlAuth('signUp?'),
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
      return message;
    } else {
      await http.patch(Uri.parse('$firebaseUrl/users.json'),
          body: json.encode({
            "${responseData['localId']}": {
              'localId': responseData['localId'],
              'email': email,
              'firstname': firstname,
              'lastname': lastname,
              'password': password,
              'admin': {'admin': isAdmin},
              'allowedInApp': {'allowedInApp': isAllowedInApp},
              'online': {'online': false},
              'loginDetails': {'init': true},
            },
          }));
    }
    message = 'Welcome,\n$firstname $lastname';
    return message;
  }

  static Future<String> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // todo if didn't log out, shared preferences force logout
    final response = await http.post(_urlAuth('signInWithPassword?'),
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    String message;
    bool isAllowed = false;
    bool isPermitted = false;

    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
      return message;
    }
    SignInData signInData = SignInData.fromMap(responseData);
    _token = signInData.idToken;
    _expiresIn = signInData.expiresIn;

    final allUsers = await http.get(Uri.parse('$firebaseUrl/.json'));
    final allUsersData = json.decode(allUsers.body) as Map<String, dynamic>;

    User? user;
    (allUsersData['users'] as Map).forEach((userId, userData) async {
      user = User.fromMap(userData as Map<String, dynamic>);
      if (userId == signInData.localId) {
        if (user!.allowedInApp['allowedInApp'] == isAllowedInApp) {
          isAllowed = true;
        }
        if (allUsersData['appActive'] == appActive) {
          isPermitted = true;
        }
        if (isAllowed && isPermitted) {
          Provider.of<FirebaseUserData>(context, listen: false)
              .setLoggedInUser(user!);
         await http.patch(
              Uri.parse('$firebaseUrl/users/${user!.localId}/online.json'),
              body: json.encode({"online": true}));
          final prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey(FirebaseUserData.prefName)) {
            final fingerprintData =
                json.decode(prefs.getString(FirebaseUserData.prefName)!)
                    as Map<String, dynamic>;
            if (email != fingerprintData['email'] as String) {
              prefs.remove(FirebaseUserData.prefName);
              Future.delayed(Duration.zero).then((_) =>
                  Provider.of<FirebaseUserData>(context, listen: false)
                      .setSwitchVal(false));

            }
          }
        }
      }
    });

    if (!isAllowed) {
      message = 'User not authorized by admin to access the app';
    } else if (!isPermitted) {
      message = 'SYSTEM IS OFF';
    } else {
      _loginTime = DateTime.now();
      message = 'Welcome';
    }
    return message;
  }

  static Future<String> updateEmailPassword(
      {required String email,
      required String password,
      required String idToken}) async {
    String message = "error";
    final response = await http.post(_urlAuth('update?'),
        body: json.encode({
          "idToken": _token,
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
    } else {
      _token = responseData['idToken'];
      _expiresIn = "3600";
      message = "UPDATE SUCCESSFUL";
    }
    return message;
  }

  static Future<String> deleteAccount() async {
    String message = "error";
    final response = await http.post(_urlAuth('delete?'),
        body: json.encode({
          "idToken": _token,
        }));
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
    } else {
      message = "DELETE SUCCESSFUL";
    }
    return message;
  }

  // todo logout
  static Future<void> logout(BuildContext context) async {
    _logoutTime = DateTime.now();

    Map<String, String> loginDetailsCurrent = {
      'login': _loginTime!.toIso8601String(),
      'logout': _logoutTime!.toIso8601String()
    };
    final loggedUser = Provider.of<FirebaseUserData>(context, listen: false);
     await http.patch(
        Uri.parse(
            '$firebaseUrl/users/${loggedUser.loggedInUser!.localId}/online.json'),
        body: json.encode({"online": false}));
    await http
        .post(
            Uri.parse(
                '$firebaseUrl/users/${loggedUser.loggedInUser!.localId}/loginDetails.json'),
            body: json.encode(loginDetailsCurrent))
        .then((_) {
      _token = null;
      _expiresIn = null;
      _loginTime = null;
      _logoutTime = null;
      loggedUser.nullifyLoggedInUser();
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
  }

// todo autoLogout
//  if token expires,
//  if after 10 minutes system is off
}
