import 'dart:async';

import 'package:festomps/providers/firebase_auth.dart';
import 'package:festomps/screens/home_screen.dart';
import 'package:festomps/widgets/admin_allow_users.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../models/admin.dart';
import '../models/user.dart';
import '../private_data.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);
  static const routeName = '/admin_screen';

  static String formatDate(DateTime time) =>
      DateFormat('dd/MM/yyyy hh:mm').format(time);

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

  Future<void> _allowUser(bool addUser, Admin user) async {
    setState(() => _isLoading = true);
    if (addUser) {
      await http
          .patch(
              Uri.parse(
                  '$firebaseUrl/users/${user.localId}/allowedInApp.json?auth=${FirebaseAuthenticationHandler.token}'),
              body: json.encode({'allowedInApp': isAllowedInApp}))
          .then((_) => setState(() => _isLoading = false));
    } else {
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
    final List<Admin> allUsersList = [];
    final List<Admin> allowUsersList = [];
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: _isLoading ? null : HomeScreen.appBar(scaffoldKey, 'Admin'),
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
                  allUsersList.clear();
                  allowUsersList.clear();
                  // onlineUsersList.clear();

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
                        '$timeInHrs hrs';
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
                    }
                    allUsersList.add(newUser);
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Custom.titleText('\nONLINE USERS'),
                        // ...onlineUsersList.map((e) => Text(e.email)).toList(),
                        if (allowUsersList.isNotEmpty)
                          AdminAllowUsers(allowUsersList, _allowUser),
                        Custom.titleText('\nALL USERS'),
                        ...allUsersList.map((Admin user) => Text('''
                email\t${user.email}:{
                First Name\t${user.firstName},
                Last Name\t${user.lastName},
                online\t${user.online},
                allowed in\t${user.allowedInApp},
                admin priv\t${user.admin},
                id\t${user.localId},
                LoginData\t${user.loginData},} 
                ''')).toList(),
                      ],
                    ),
                  );
                }),
      ),
    );
  }
}
