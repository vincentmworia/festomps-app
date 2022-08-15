import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../private_data.dart';
import '../providers/firebase_user_data.dart';
import '../models/signIn.dart';
import '../models/user.dart';

class FirebaseAuthenticationHandler with ChangeNotifier {
  static String? _token;
  static String? _expiresIn;

  String? get token => _token;

  // todo, token expire? force log out and reset preferences

  static Uri _urlAuth(String operation) => Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:${operation}key=$webApiKey');
  static final Uri usersUrl = Uri.parse('$firebaseUrl/users.json');
  static List<User>? otherUsers;

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
      await http.patch(usersUrl,
          body: json.encode({
            "${responseData['localId']}": {
              'localId': responseData['localId'],
              'email': email,
              'firstname': firstname,
              'lastname': lastname,
              'password': password,
              'admin': isNotAdmin,
              'allowedInApp': isNotAllowedInApp,
              'online': false,
              'loginDetails': [
                {'login': '', 'logout': ''},
              ],
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
    final response = await http.post(_urlAuth('signInWithPassword?'),
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    String message;
    bool isAuthenticated = false;
    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
      return message;
    }
    SignInData signInData = SignInData.fromMap(responseData);
    _token = signInData.idToken;
    _expiresIn = signInData.expiresIn;
    final allUsers = await http.get(Uri.parse('$firebaseUrl/users.json'));
    final allUsersData = json.decode(allUsers.body) as Map<String, dynamic>;
    otherUsers = [];
    allUsersData.forEach((userId, userData) {
      User user = User.fromMap(userData as Map<String, dynamic>);
      if (userId == signInData.localId) {
        Provider.of<FirebaseUserData>(context, listen: false)
            .setLoggedInUser(user);
        if (user.allowedInApp == isAllowedInApp) {
          isAuthenticated = true;
        }
      }
      otherUsers!.add(user);
    });
    message = isAuthenticated
        ? 'Welcome'
        : 'User not authorized by admin to access the app';
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
      print(responseData['error']);
      message = getErrorMessage(responseData['error']['message']);
    } else {
      _token = responseData['idToken'];
      _expiresIn = "3600";

      print(responseData["email"]);
      print(responseData["passwordHash"]);

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

    // todo delete fails here
    print(responseData['error']);
    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
    } else {
      message = "DELETE SUCCESSFUL";
    }
    return message;
  }
}
