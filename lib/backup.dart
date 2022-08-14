
import 'dart:convert';
import 'dart:async';

import 'package:festomps/private_data.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import './models/user.dart';
import './widgets/http_exception.dart';

class FirebaseAuthenticationHandler with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  String? _userEmail;
  Timer? _authTimer;
  User? _user;
  List<User>? _usersData;

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token!;
    }
    return null;
  }

  String? get userEmail => _userEmail;

  String? get userId => _userId;

  User get loggedInUser => _user!;

  List<User>? get usersData => _usersData;

  bool get isAuthenticated => token != null;

  Future<void> _authenticate(String firstName, String lastName, String email,
      String password, String operation) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:${operation}key=$webApiKey',
    );
    final response = await http.post(uri,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    if (kDebugMode) {
      print(responseData);
    }
    if (responseData['error'] != null) {
      // print('error');
      throw HttpException(responseData['error']['message']);
    } else {
      if (operation == 'signUp?') {
          await http.patch(Uri.parse('$firebaseUrl/Users.json'),
              body: json.encode({
                "${responseData['localId']}": {
                  "email": email,
                  "firstname": firstName,
                  "lastname": lastName,
                  "isAdmin": false,
                  "isAllowedInApp": false,
                  "isOnline": false,
                }
              }));
        if (kDebugMode) {
          print('patch');
        }
        return;
      }
      if (operation == 'signInWithPassword?') {
        _usersData = [];

        final allUserDataMain =
        await http.get(Uri.parse('$firebaseUrl/Users.json'));
        final allUsrData =
        json.decode(allUserDataMain.body) as Map<String, dynamic>;
        List<User> firebaseData = [];
        User? userLoggedIn;
        allUsrData.forEach((userId, usrData) {
          // User usr = User(
          //   id: userId,
          //   email: usrData['email'] as String,
          //   firstName: usrData['firstname'] as String,
          //   lastName: usrData['lastname'] as String,
          //   isAllowedInApp: usrData['isAllowedInApp'] as int,
          //   isAdmin: usrData['isAdmin'] as int,
          //   isOnline: usrData['isOnline'] as bool,
          //   loginDetails: usrData['loginDetails'] as List<dynamic>?,
          //   password: password,
          // );
          User usr = User.fromMap(allUsrData);
          // print(usr);
          firebaseData.insert(0, usr);
          if (userId == responseData['localId']) {
            userLoggedIn = usr;
            _user = userLoggedIn;
          }
        });

        if (_user!.allowedInApp != 0163) {
          throw HttpException('NOT_ALLOWED');
        } else {
          if (kDebugMode) {
            print('allowed');
          }
          _user!.online = true;
          await http.patch(
              Uri.parse('$firebaseData/Users/${userLoggedIn!.id}.json'),
              body: json.encode({"isOnline": true}));
          // _user!.loggedInTime = DateTime.now();
          // _userId = _user!.localId;
        }
        if (_user!.admin == 5334) {
          _usersData = firebaseData;
        }
        _token =
        (_user!.allowedInApp == 0163) ? responseData['idToken'] : null;
        _userId = responseData['localId'];
        _userEmail = responseData['email'];
        _expiryDate = DateTime.now().add(Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ));
        if (_token != null && _userId != null && _expiryDate != null) {
          _autoLogout();
        }
      }
    }
    _token =  (_user!.allowedInApp == 0163)? responseData['idToken'] : null;
    _userId = responseData['localId'];
    _userEmail = responseData['email'];
    _expiryDate = DateTime.now().add(Duration(
      seconds: int.parse(
        responseData['expiresIn'],
      ),
    ));

    notifyListeners();

    // final prefs = await SharedPreferences.getInstance();
    // List list =
    //     _usersData!.map((user) => user.toMap()).toList();
    // final userData = json.encode({
    //   'token': _token,
    //   'userId': _userId,
    //   'expiryDate': _expiryDate?.toIso8601String(),
    //   'userEmail': _userEmail,
    //   'loggedInUser': _user!.toMap(),
    //   'usersData': [...list],
    //   'loginTime': _user!.loggedInTime!.toIso8601String()
    // });
    // prefs.setString('userData', userData);
    // if (HomeScreen.inScreen == false) {
    //   throw HttpException('FORCE_LOGIN_SUCCESSFUL');
    // }
  }

  Future<void> signup(
      String firstName, String lastName, String email, String password) async {
    return _authenticate(firstName, lastName, email, password, 'signUp?');
  }

  Future<void> login(
      String firstName, String lastName, String email, String password) async {
    return _authenticate(
        firstName, lastName, email, password, 'signInWithPassword?');
  }

  // Future<void> _makeUserOffline(User user) async {
  //   user.loggedOutTime = DateTime.now();
  //   user.isOnline = false;
  //   Map<String, String> loginLogoutData = user.addLoginDetails();
  //   List<dynamic> newLoginData = [
  //     ...(user.loginDetails ?? []),
  //     loginLogoutData
  //   ];
  //   user.loginDetails = newLoginData;
  //   await http.patch(
  //       Uri.parse('${GlobalData.mainEndpointUrl}/Users/${user.localId}.json'),
  //       body: json.encode({
  //         "isOnline": false,
  //         "loginDetails": [...user.loginDetails ?? []],
  //       }));
  // }

  // Future<bool> tryAutoLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey('userData')) {
  //     return false;
  //   }
  //   final extractedUserData =
  //       json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
  //   final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
  //
  //   if (expiryDate.isBefore(DateTime.now())) {
  //     return false;
  //   }
  //
  //   User userLoggedIn = User.fromMap(extractedUserData['loggedInUser']);
  //   List<dynamic> allUsr = (extractedUserData['usersData'] as List)
  //       .map((userMap) => User.fromMap(userMap))
  //       .toList();
  //   _token = extractedUserData['token'];
  //   _userId = extractedUserData['userId'];
  //   _expiryDate = expiryDate;
  //   _userEmail = extractedUserData['userEmail'];
  //   _user = userLoggedIn;
  //   _user!.loggedInTime = DateTime.parse(extractedUserData['loginTime']);
  //   _usersData = allUsr as List<User>;
  //   _autoLogout();
  //
  //   notifyListeners();
  //   return true;
  // }

  void logout() async {
    // if (_user != null) {
    //   _makeUserOffline(_user!);
    // }
    _token = null;
    _expiryDate = null;
    _userId = null;
    _userEmail = null;
    _user = null;
    _usersData = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel(); // Cancels the previous timer and re-initializes it
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}