import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../private_data.dart';
import '../providers/firebase_user_data.dart';
import '../models/signIn.dart';
import '../models/user.dart';

class FirebaseAuthenticationHandler with ChangeNotifier {
  static Uri _urlAuth(String operation) => Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:${operation}key=$webApiKey');
  static final Uri _urlRTdb = Uri.parse('$firebaseUrl/users.json');

  static String getErrorMessage(String errorTitle) {
    var message = 'Authentication failed';

    if (errorTitle.contains('EMAIL_EXISTS')) {
      message = 'Email is already in use';
    } else if (errorTitle.contains('INVALID_EMAIL')) {
      message = 'This is not a valid email address';
    } else if (errorTitle.contains('NOT_ALLOWED')) {
      message = 'User needs to be allowed by the admin';
    } else if (errorTitle.contains('OPERATION_NOT_ALLOWED:')) {
      message = 'Password sign-in is disabled for this project';
    } else if (errorTitle.contains('TOO_MANY_ATTEMPTS_TRY_LATER:')) {
      message =
          'We have blocked all requests from this device due to unusual activity. Try again later.';
    } else if (errorTitle.contains('EMAIL_NOT_FOUND')) {
      message = 'Could not find a user with that email.';
    } else if (errorTitle.contains('WEAK_PASSWORD')) {
      message = 'Password must be at least 6 characters';
    } else if (errorTitle.contains('INVALID_PASSWORD')) {
      message = 'Invalid password';
    } else if (errorTitle.contains('FORCE_LOGIN_SUCCESSFUL')) {
      message = 'no error';
      // todo MANUAL OVERRIDE
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
      await http.patch(_urlRTdb,
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
    String? message;
    final responseData = json.decode(response.body) as Map<String, dynamic>;

    if (responseData['error'] != null) {
      message = getErrorMessage(responseData['error']['message']);
      return message;
    }
    SignInData signInData = SignInData.fromMap(responseData);
    final allUsers = await http.get(Uri.parse('$firebaseUrl/users.json'));
    final allUsersData = json.decode(allUsers.body) as Map<String, dynamic>;
    final List<User> otherUsers = [];
    allUsersData.forEach((userId, userData) {
      User user = User.fromMap(userData as Map<String, dynamic>);
      if (userId == signInData.localId) {
        Provider.of<FirebaseUserData>(context).setLoggedInUser(user);
      } else {
        otherUsers.add(user);
      }
    });
    message = 'Welcome';
    return message;
  }
}
