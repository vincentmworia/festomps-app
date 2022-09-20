import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../main.dart';
import '../providers/firebase_auth.dart';
import '../widgets/admin_allow_users.dart';
import '../widgets/admin_other_users.dart';
import '../models/admin.dart';
import '../models/user.dart';
import '../private_data.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);
  static const routeName = '/admin_screen';

  static String formatDate(DateTime time) =>
      DateFormat('dd/MM/yyyy HH:mm:ss').format(time);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // todo, Timer.periodic, in case there is change only, re-render the widget
  static final List<User> otherUsers = [];
  var _isLoading = false;

  Future<List<dynamic>> _getUsersData() async {
    final allUsers = await http.get(Uri.parse(
        '$firebaseUrl/.json?auth=${FirebaseAuthenticationHandler.token}'));
    final allUsersData = json.decode(allUsers.body) as Map<String, dynamic>;
    otherUsers.clear();
    User? user;
    allUsersData['users'].forEach((userId, userData) {
      user = User.fromMap(userData as Map<String, dynamic>);
      otherUsers.add(user!);
    });
    return otherUsers;
  }

  Future<void> _allowUser(int addUser, Admin user) async {
    setState(() => _isLoading = true);
    if (addUser == 1) {
      await http
          .patch(
              Uri.parse(
                  '$firebaseUrl/users/${user.localId}/allowedInApp.json?auth=${FirebaseAuthenticationHandler.token}'),
              body: json.encode({'allowedInApp': isAllowedInApp}))
          .then((_) => setState(() => _isLoading = false));
    } else if (addUser == 2) {
      // make allowed in app false
      await http
          .patch(
              Uri.parse(
                  '$firebaseUrl/users/${user.localId}/allowedInApp.json?auth=${FirebaseAuthenticationHandler.token}'),
              body: json.encode({'allowedInApp': isNotAllowedInApp}))
          .then((_) => setState(() => _isLoading = false));
    } else if (addUser == 3) {
      // make user admin
      await http
          .patch(
              Uri.parse(
                  '$firebaseUrl/users/${user.localId}/admin.json?auth=${FirebaseAuthenticationHandler.token}'),
              body: json.encode({'admin': isAdmin}))
          .then((_) => setState(() => _isLoading = false));
    } else if (addUser == 4) {
      await http
          .patch(
              Uri.parse(
                  '$firebaseUrl/users/${user.localId}/admin.json?auth=${FirebaseAuthenticationHandler.token}'),
              body: json.encode({'admin': isNotAdmin}))
          .then((_) => setState(() => _isLoading = false));
    } else if (addUser == 0) {
      await http
          .delete(Uri.parse(
              '$firebaseUrl/users/${user.localId}.json?auth=${FirebaseAuthenticationHandler.token}'))
          .then((value) => setState(() => _isLoading = false));
    }
  }

  @override
  void initState() {
    super.initState();
    // _searchController=TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    // _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    // final List<Admin> onlineUsersList = [];
    final List<Admin> otherUsersList = [];
    final List<Admin> allowUsersList = [];
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: Custom.appBar(scaffoldKey, 'Admin'),
        drawer: const CustomDrawer(),
        body: _isLoading
            ? Custom.containerLoading(deviceHeight)
            : FutureBuilder(
                future: _getUsersData(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Custom.containerLoading(deviceHeight);
                  }
                  // i++;
                  otherUsersList.clear();
                  allowUsersList.clear();
                  // onlineUsersList.clear();

                  if (snap.data == null) {
                    return Container(
                      height: deviceHeight,
                      color: MyApp.appPrimaryColor.withOpacity(0.75),
                      child: const Center(
                        child: Text(
                          'OFFLINE',
                          style: TextStyle(
                              letterSpacing: 20.0,
                              color: Colors.white,
                              fontSize: 30.0),
                        ),
                      ),
                    );
                  }

                  for (User user in snap.data as List<User>) {
                    var loginData = [];
                    final userLogins =
                        (user.loginDetails as Map<String, dynamic>)
                            .values
                            .toList();
                    userLogins.removeWhere((data) => data == true);
                    for (Map<String, dynamic> logins in userLogins) {
                      final loginTime = DateTime.parse(logins['login']);
                      final logoutTime = DateTime.parse(logins['logout']);
                      final loginDuration = logoutTime.difference(loginTime);

                      var timeInHrs = loginDuration.inHours.toString();
                      var timeInMin = loginDuration.inMinutes.toString();
                      var timeInSec = loginDuration.inSeconds.toString();
                      var timeInMilliSec =
                          loginDuration.inMilliseconds.toString();

                      String? duration;
                      if (timeInMin == '0' &&
                          timeInHrs == '0' &&
                          timeInSec == '0') {
                        duration = '$timeInMilliSec mill';
                      } else if (timeInMin == '0' && timeInHrs == '0') {
                        duration = '$timeInSec sec';
                      } else if (timeInHrs == '0') {
                        duration = '$timeInMin min';
                      } else {
                        '$timeInHrs hrs $timeInMin min';
                      }

                      loginData.add({
                        'login': AdminScreen.formatDate(loginTime),
                        'logout': AdminScreen.formatDate(logoutTime),
                        'duration': duration,
                      });
                    }

                    final newUser = Admin(
                        localId: user.localId,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        password: user.password,
                        admin: user.admin['admin'] == isAdmin,
                        allowedInApp:
                            user.allowedInApp['allowedInApp'] == isAllowedInApp,
                        online: user.online['online'] as bool,
                        loginData: loginData);
                    if (!newUser.allowedInApp) {
                      allowUsersList.add(newUser);
                    } else {
                      otherUsersList.add(newUser);
                    }
                  }

                  return SingleChildScrollView(
                    child: SizedBox(
                      height: deviceHeight * 0.9,
                      child: Column(
                        children: [
                          if (allowUsersList.isNotEmpty)
                            AdminAllowUsers(allowUsersList, _allowUser),
                          Expanded(
                              child:
                                  AdminOtherUsers(otherUsersList, _allowUser)),
                        ],
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
